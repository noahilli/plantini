const { ApplicationError } = require("@strapi/utils").errors;

module.exports = {
  async beforeCreate(event) {
    const { data } = event.params;
    if (data.publishedAt) {
      if (data.reviewStatus !== "approved") {
        throw new ApplicationError("Botanischer Review erforderlich: Plant muss den Status \"approved\" haben, bevor er veröffentlicht wird.");
      }
    }
  },
  async beforeUpdate(event) {
    const { data } = event.params;
    // data.publishedAt might be explicitly set to null when unpublishing.
    // If it is set to a date, it means it is being published.
    if (data.publishedAt) {
      // We might need to fetch the current entry if reviewStatus is not in the update payload
      const id = event.params.where.id;
      const currentEntry = await strapi.entityService.findOne("api::plant.plant", id);
      
      const nextReviewStatus = data.reviewStatus !== undefined ? data.reviewStatus : currentEntry.reviewStatus;
      
      if (nextReviewStatus !== "approved") {
        throw new ApplicationError("Botanischer Review erforderlich: Plant muss den Status \"approved\" haben, bevor er veröffentlicht wird.");
      }
    }
  }
};
