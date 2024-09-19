package components

import (
	"fmt"
	"{{.GoModulePath}}/model"
	"{{.GoModulePath}}/ui/components/icons"
)

templ TodoItem(todo model.Todo) {
	<div class="relative mb-4 p-3 shadow-md bg-white border rounded">
		<div
			class={ "text-2xl font-bold break-all",
            templ.KV("text-gray-400", todo.Completed),
            templ.KV( "text-indigo-600", !todo.Completed),
            templ.KV("line-through", todo.Completed) }
		>
			{ todo.Text }
		</div>
		<div class="mt-2 text-gray-500 text-sm flex justify-between items-center">
			<div class="flex items-center">
				<div class="mx-1">
					@icons.Clock()
				</div>
				<div>
					{ todo.Timestamp.Format("2006/01/02 15:04:05") }
				</div>
			</div>
			<div>
				<button
					hx-put={ fmt.Sprintf("/components/todo_item/%s/toggle", todo.Id) }
					class={ "outline-none focus:outline-none", templ.KV("text-green-600",  todo.Completed) }
				>
					@icons.Check()
				</button>
				<button
					hx-delete={ fmt.Sprintf("/components/todo_item/%s", todo.Id) }
					class="outline-none focus:outline-none ml-4 focus:text-red-600"
				>
					@icons.Trash()
				</button>
			</div>
		</div>
	</div>
}
