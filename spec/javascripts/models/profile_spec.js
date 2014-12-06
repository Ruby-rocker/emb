describe("Profile", function() {
  beforeEach(function() {
    Ember.testing = true;
  });

  describe("Full Name", function() {
    it("builds the fullName from the firstName and lastName", function() {
      Ember.run(function() {
        profile = Yostalgia.Profile.createRecord({firstName: 'Test', lastName: 'User'});
        expect(profile.get('fullName')).toEqual('Test User');
      });
    });

    it("populates the firstName and lastName from fullName", function() {
      Ember.run(function() {
        profile = Yostalgia.Profile.createRecord();
        profile.set('fullName', 'Test User');
        expect(profile.get('firstName')).toEqual('Test');
        expect(profile.get('lastName')).toEqual('User');
      });
    });

    it("handles names with more than one space", function() {
      Ember.run(function() {
        profile = Yostalgia.Profile.createRecord();
        profile.set('fullName', 'Test User Two');
        expect(profile.get('firstName')).toEqual('Test');
        expect(profile.get('lastName')).toEqual('User Two');
      });
    });
  });

  describe("Gender", function() {
    describe("isMale", function() {
      it("returns true when 'Male'", function() {
        Ember.run(function() {
          profile = Yostalgia.Profile.createRecord({gender: 'Male'});
          expect(profile.get('isMale')).toEqual(true);
        });
      });

      it("returns false when 'Female'", function() {
        Ember.run(function() {
          profile = Yostalgia.Profile.createRecord({gender: 'Female'});
          expect(profile.get('isMale')).toEqual(false);
        });
      });
    });

    describe("isFemale", function() {
      it("returns false when 'Male'", function() {
        Ember.run(function() {
          profile = Yostalgia.Profile.createRecord({gender: 'Male'});
          expect(profile.get('isFemale')).toEqual(false);
        });
      });

      it("returns true when 'Female'", function() {
        Ember.run(function() {
          profile = Yostalgia.Profile.createRecord({gender: 'Female'});
          expect(profile.get('isFemale')).toEqual(true);
        });
      });
    });
  });
});
