package components

import (
	"{{.GoModulePath}}/ui/components/icons"
	"{{.GoModulePath}}/model"
)

templ TodoList(todos []*model.Todo) {
	<div className="mt-6">
		if len(todos) == 0 {
			<div class="p-6 flex items-center justify-center">
				<div class="">
					@icons.FolderOpenIcon()
				</div>
				<div class="px-1 text-xl">NOTHING HERE!</div>
			</div>
		} else {
			for _, todo := range todos {
				@TodoItem(*todo)
			}
		}
	</div>
}
