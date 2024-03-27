var LoginService = {
  methods: {
    execLogin(body, success, error) {
      this.$http
        .post(
          this.$root.$options.api_scheme +
            this.$root.$options.api_host +
            "/api/login",
          body
        )
        .then(success, error);
    },
    execLogout(success, error) {
      this.$http
        .post(
          this.$root.$options.api_scheme +
            this.$root.$options.api_host +
            "/api/logout",
          {},
          {
            headers: {
              Token:
                (this.get("loggedUser") && this.get("loggedUser").token) || ""
            }
          }
        )
        .then(success, error);
    },
    execGetInfo(id, success, error) {
      this.$http
        .get(
          this.$root.$options.api_scheme +
            this.$root.$options.api_host +
            "/api/accounts/" +
            id,
          {
            headers: {
              Token:
                (this.get("loggedUser") && this.get("loggedUser").token) || ""
            }
          }
        )
        .then(success, error);
    },
    execChangePassword(password, id, success, error) {
      this.$http
        .put(
          this.$root.$options.api_scheme +
            this.$root.$options.api_host +
            "/api/accounts/" +
            id,
          {
            password: password
          },
          {
            headers: {
              Token:
                (this.get("loggedUser") && this.get("loggedUser").token) || ""
            }
          }
        )
        .then(success, error);
    }
  }
};
export default LoginService;
