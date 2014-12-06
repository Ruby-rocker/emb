describe("User", function() {
  beforeEach(function() {
    Ember.testing = true;
  });

  describe("#signup", function() {
    var user;
    var profile;

    beforeEach(function() {
      Ember.run(function() {
        profile = Yostalgia.Profile.createRecord({
          firstName: 'Test',
          lastName: 'User'
        });
        user = Yostalgia.User.createRecord({
          username: 'testuser',
          email: 'test@example.com',
          password: 'password',
          profile: profile
        });
      });

      spyOn($, 'ajax');
    });

    it("calls the correct url", function() {
      Ember.run(function() {
        user.signup();
        expect($.ajax.mostRecentCall.args[0]['url']).toEqual('/api/v1/users');
      });
    });

    it("supplies the correct data format", function() {
      Ember.run(function() {
        user.signup()
        expect($.ajax.mostRecentCall.args[0]['data']).toEqual({
          user: {
            email: 'test@example.com',
            username: 'testuser',
            password: 'password',
            profile_attributes: {
              first_name: 'Test',
              last_name: 'User'
            }
          }
        });
      });
    });
  });

  describe(".checkEmail", function() {
    it("hits the correct URL", function() {
      spyOn($, 'ajax');
      Yostalgia.User.checkEmail('test@example.com');
      expect($.ajax.mostRecentCall.args[0]['url']).toEqual('/api/v1/users/check_email')
    });
  });

  describe(".checkUsername", function() {
    it("hits the correct URL", function() {
      spyOn($, 'ajax');
      Yostalgia.User.checkUsername('testuser');
      expect($.ajax.mostRecentCall.args[0]['url']).toEqual('/api/v1/users/check_username')
    });
  });
});
