package pages

import (
	commonComponents "{{.GoModulePath}}/ui/components"
	"{{.GoModulePath}}/ui/pages/components"
)

templ Page() {
	<html lang="en">
		<head>
			<meta charset="UTF-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
			<meta http-equiv="X-UA-Compatible" content="ie=edge"/>
			<title>Todo</title>
			<script src="/public/static/htmx.min.js"></script>
			<script src="/public/static/json-enc.js"></script>
			<link href="/public/static/output.css" rel="stylesheet"/>
		</head>
		<body>
			<div class="container mx-auto p-4 max-w-md">
				<h1 class="p-4 text-4xl font-bold text-center">TodoMVC with Go, Htmx & Tailwind CSS</h1>
				@commonComponents.Clock()
				@components.TodoForm()
				<div hx-get="/components/todo_list" hx-trigger="updateTodoList from:body, load"></div>
			</div>
		</body>
	</html>
}
