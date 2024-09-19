package components

templ Clock() {
	<p id="date" class="text-center pb-4">
		@updateDateTime()
	</p>
}

script updateDateTime() {
  function updateDateTime() {
    const now = new Date();

    const dateP = document.getElementById("date");
    dateP.innerText = now.toLocaleDateString() + " " + now.toLocaleTimeString();
  }

  updateDateTime();
  setInterval(updateDateTime, 1);
}
