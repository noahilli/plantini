const { ApplicationError } = require("@strapi/utils").errors;

module.exports = {
  async beforeCreate(event) {
    const { data } = event.params;
    if (data.publishedAt) {
      if (data.reviewStatus !== "approved") {
        throw new ApplicationError("Botanischer Review erforderlich: Quiz muss den Status \"approved\" haben, bevor es veröffentlicht wird.");
      }
    }
  },
  async beforeUpdate(event) {
    const { data } = event.params;
    if (data.publishedAt) {
      const id = event.params.where.id;
      const currentEntry = await strapi.entityService.findOne("api::quiz.quiz", id);
      
      const nextReviewStatus = data.reviewStatus !== undefined ? data.reviewStatus : currentEntry.reviewStatus;
      
      if (nextReviewStatus !== "approved") {
        throw new ApplicationError("Botanischer Review erforderlich: Quiz muss den Status \"approved\" haben, bevor es veröffentlicht wird.");
      }
    }
  }
};
