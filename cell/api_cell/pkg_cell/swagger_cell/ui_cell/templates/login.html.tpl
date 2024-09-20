<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Swagger Login</title>
    <style>
      body {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
        font-family: "Arial", sans-serif;
        background-color: #f4f4f4;
      }

      form {
        text-align: center;
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
      }

      label {
        display: block;
        margin-bottom: 8px;
        font-size: 16px;
        color: #333;
      }

      input {
        width: 100%;
        padding: 10px;
        margin-bottom: 16px;
        border: 1px solid #ccc;
        border-radius: 4px;
        box-sizing: border-box;
        font-size: 14px;
      }

      button {
        background-color: #4caf50;
        color: #fff;
        border: none;
        padding: 12px 20px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 16px;
        opacity: 0.8;
      }

      button:hover {
        background-color: #45a049;
        opacity: 1;
      }

      button:disabled {
        background-color: #ccc;
        cursor: not-allowed;
      }
    </style>
  </head>
  <body>
    <form id="tokenForm">
      <label for="token">Access Token:</label>
      <input
        type="password"
        id="token"
        name="token"
        required
        oninput="enableButton()"
      />
      <button type="button" id="accessButton" onclick="setToken()" disabled>
        Access
      </button>
    </form>

    <script>
      window.onload = function () {
        var storedToken = getCookie("core_token");
        if (storedToken) {
          document.getElementById("token").value = storedToken;
          enableButton();
        }
      };

      function enableButton() {
        var tokenValue = document.getElementById("token").value;
        var accessButton = document.getElementById("accessButton");
        accessButton.disabled = tokenValue.trim() === "";
      }

      function setToken() {
        var tokenValue = document.getElementById("token").value;
        setCookie("core_token", tokenValue, 7);
        window.location.href = "/swagger/ui/index.html";
      }

      function setCookie(name, value, days) {
        const expires = new Date();
        expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
        document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`;
      }

      function getCookie(name) {
        var nameEQ = name + "=";
        var cookies = document.cookie.split(";");
        for (var i = 0; i < cookies.length; i++) {
          var cookie = cookies[i];
          while (cookie.charAt(0) == " ") {
            cookie = cookie.substring(1, cookie.length);
          }
          if (cookie.indexOf(nameEQ) == 0) {
            return cookie.substring(nameEQ.length, cookie.length);
          }
        }
        return null;
      }
    </script>
  </body>
</html>
