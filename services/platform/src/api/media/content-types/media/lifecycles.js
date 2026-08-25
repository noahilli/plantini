const { ApplicationError } = require("@strapi/utils").errors;

module.exports = {
  async beforeCreate(event) {
    const { data } = event.params;
    if (!data.author || data.author.trim() === "") {
      throw new ApplicationError("Media must have a valid author.");
    }
    if (!data.license || data.license.trim() === "") {
      throw new ApplicationError("Media must have a valid license.");
    }
  },
  async beforeUpdate(event) {
    const { data } = event.params;
    
    // In updates, properties might be omitted if unchanged.
    // Only check if they are explicitly passed as empty.
    if (data.author !== undefined && (data.author === null || data.author.trim() === "")) {
      throw new ApplicationError("Media author cannot be empty.");
    }
    if (data.license !== undefined && (data.license === null || data.license.trim() === "")) {
      throw new ApplicationError("Media license cannot be empty.");
    }
  }
};
