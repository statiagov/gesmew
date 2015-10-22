var alt = require('../alt');

class RubricAssessmentActions {
  updateScore(obj) {
    this.dispatch(obj);
  }

  removeCriteria(id){
    this.dispatch(id);
  }

  toggleEditMode(codition){
    this.dispatch(codition)
  }
}

module.exports = alt.createActions(RubricAssessmentActions);
