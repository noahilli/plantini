'use strict';
module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/quizzes',
      handler: 'quiz.find',
      config: { auth: false },
    }
  ]
};
