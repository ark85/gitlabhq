require 'rails_helper'

describe 'Issue Boards add issue modal filtering', :feature, :js do
  include WaitForAjax
  include WaitForVueResource

  let(:project) { create(:empty_project, :public) }
  let(:board) { create(:board, project: project) }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:issue1) { create(:issue, project: project) }

  before do
    project.team << [user, :master]

    login_as(user)
  end

  context 'author' do
    let!(:issue) { create(:issue, project: project, author: user2) }

    before do
      project.team << [user2, :developer]

      visit_board
    end

    it 'filters by any author' do
      page.within('.add-issues-modal') do
        click_button 'Author'

        wait_for_ajax

        click_link 'Any Author'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 2)
      end
    end

    it 'filters by selected user' do
      page.within('.add-issues-modal') do
        click_button 'Author'

        wait_for_ajax

        click_link user2.name

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end
  end

  context 'assignee' do
    let!(:issue) { create(:issue, project: project, assignee: user2) }

    before do
      project.team << [user2, :developer]

      visit_board
    end

    it 'filters by any assignee' do
      page.within('.add-issues-modal') do
        click_button 'Assignee'

        wait_for_ajax

        click_link 'Any Assignee'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 2)
      end
    end

    it 'filters by unassigned' do
      page.within('.add-issues-modal') do
        click_button 'Assignee'

        wait_for_ajax

        click_link 'Unassigned'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end

    it 'filters by selected user' do
      page.within('.add-issues-modal') do
        click_button 'Assignee'

        wait_for_ajax

        page.within '.dropdown-menu-user' do
          click_link user2.name
        end

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end
  end

  context 'milestone' do
    let(:milestone) { create(:milestone, project: project) }
    let!(:issue) { create(:issue, project: project, milestone: milestone) }

    before do
      visit_board
    end

    it 'filters by any milestone' do
      page.within('.add-issues-modal') do
        click_button 'Milestone'

        wait_for_ajax

        click_link 'Any Milestone'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 2)
      end
    end

    it 'filters by upcoming milestone' do
      page.within('.add-issues-modal') do
        click_button 'Milestone'

        wait_for_ajax

        click_link 'Upcoming'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 0)
      end
    end

    it 'filters by selected milestone' do
      page.within('.add-issues-modal') do
        click_button 'Milestone'

        wait_for_ajax

        click_link milestone.name

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end
  end

  context 'label' do
    let(:label) { create(:label, project: project) }
    let!(:issue) { create(:labeled_issue, project: project, labels: [label]) }

    before do
      visit_board
    end

    it 'filters by any label' do
      page.within('.add-issues-modal') do
        click_button 'Label'

        wait_for_ajax

        click_link 'Any Label'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 2)
      end
    end

    it 'filters by no label' do
      page.within('.add-issues-modal') do
        click_button 'Label'

        wait_for_ajax

        click_link 'No Label'

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end

    it 'filters by label' do
      page.within('.add-issues-modal') do
        click_button 'Label'

        wait_for_ajax

        click_link label.title

        wait_for_vue_resource

        expect(page).to have_selector('.card', count: 1)
      end
    end
  end

  def visit_board
    visit namespace_project_board_path(project.namespace, project, board)
    wait_for_vue_resource

    click_button('Add issues')
  end
end
