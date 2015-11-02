var alt = require('../alt');
import axios from 'axios';

class RubricAssessmentActions {
  updateScore(obj) {
    this.dispatch(obj);
  }

  loadAssessment(assessment){
    this.dispatch(assessment);
  }

  saveAssessment(assessment){
    console.log(assessment)
    this.dispatch()
    // axios.put(`${Gesmew.routs.inspections_api}/${inspections_number}/assess`,{
    //   token: Gesmew.api_key,
    //
    // })
  }
}

module.exports = alt.createActions(RubricAssessmentActions);
