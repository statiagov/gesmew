var alt = require('../alt');
import axios from 'axios';

class RubricActions {
  addCriteria(criteria) {
    this.dispatch(criteria);
  }

  updateCriteria(obj) {
    this.dispatch(obj);
  }

  fetchRubric(id){
    this.dispatch();
    axios.get(`${Gesmew.routes.rubrics_api}/${id}`,{
      params: {
        token: Gesmew.api_key
      }
    }).then((response)=>{
      this.actions.updateRubricLocal(response.data);
    })
  }

  removeCriteria(id){
    this.dispatch(id);
  }

  toggleEditMode(codition){
    this.dispatch(codition)
  }

  updateRubric(rubric){
    this.dispatch();
    console.log(rubric)
    axios.put(`${Gesmew.routes.rubrics_api}/${rubric.id}`,{
      criteria: rubric.criteria,
      token: Gesmew.api_key
    }).then((response)=>{
      this.actions.updateRubricLocal(response.data);
    })
    this.dispatch(rubric)
  }

  updateRubricLocal(rubric){
    this.dispatch(rubric);
  }
}

module.exports = alt.createActions(RubricActions);
