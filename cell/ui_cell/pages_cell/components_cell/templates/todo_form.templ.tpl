package components

templ TodoForm() {
	<form hx-post="/components/todo_form" hx-trigger="submit">
		<input
			class="border-2 border-gray-600 p-4 w-full outline-none text-xl placeholder-gray-300 rounded appearance-none"
			placeholder="What needs to be done?"
			type="text"
			name="todoInput"
		/>
	</form>
}
