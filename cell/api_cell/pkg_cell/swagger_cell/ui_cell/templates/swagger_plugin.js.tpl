const SwaggerPlugin = (system) => ({
  rootInjects: {
    setToken: () => {
      console.log("setToken");
      const token = getTokenFromCookies();
      if (token) {
        window.ui.preauthorizeApiKey("ApiKeyAuth", "token " + token);
      }
      return;
    },
  },
});

function getTokenFromCookies() {
  const cookies = document.cookie;
  const cookieArray = cookies.split(";").map((cookie) => cookie.trim());

  for (const cookie of cookieArray) {
    const [name, value] = cookie.split("=");
    if (name === "core_token") {
      return value;
    }
  }

  return null;
}
