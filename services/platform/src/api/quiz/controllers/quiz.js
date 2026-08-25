"use strict";
const { createCoreController } = require("@strapi/strapi").factories;

module.exports = createCoreController("api::quiz.quiz", ({ strapi }) => ({
  async find(ctx) {
    try {
      const quizzes = await strapi.entityService.findMany('api::quiz.quiz', {
        fields: ['id', 'title', 'quizType', 'data'],
      });
      const data = quizzes.map(quiz => ({
        id: String(quiz.id),
        title: quiz.title || '',
        quizType: quiz.quizType || 'multiple-choice',
        data: quiz.data || {}
      }));
      return data;
    } catch (err) {
      ctx.throw(500, 'Error fetching quizzes');
    }
  }
}));
