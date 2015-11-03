var alt = require('../alt');
var RubricActions = require('../actions/RubricActions');
var _ = require('lodash')
var Immutable = require('immutable');
var ImmutableStore = require('alt/utils/ImmutableUtil');

class RubricStore {
  constructor(){
    this.state = {
      rubric_id: null,
      criteria: Immutable.fromJS([])
    }
    this.bindListeners({
      handleAddCriteria:       RubricActions.ADD_CRITERIA,
      handleUpdateCriteria:    RubricActions.UPDATE_CRITERIA,
      handleRemoveCriteria:    RubricActions.REMOVE_CRITERIA,
      handleToggleEditMode:    RubricActions.TOGGLE_EDIT_MODE,
      handleUpdateRubric:      RubricActions.UPDATE_RUBRIC,
      handleUpdateRubricLocal: RubricActions.UPDATE_RUBRIC_LOCAL,
      handleFetchRubric:       RubricActions.FETCH_RUBRIC
    });
  }

  static getPointTotal() {
    let arr = []
    this.state.criteria.map((c, index) =>{
      arr.push(c.get('points'));
    });
    return _.sum(arr);
  }

  handleAddCriteria(criterion){
    this.setState({
      criteria:this.state.criteria.push(criterion)
    });
  }

  handleUpdateCriteria(criterion){
    let criteriaIndex =  this.state.criteria.findIndex((s) => s.get('id') === criterion.id);
    this.setState({
      criteria: this.state.criteria.update(criteriaIndex,
        (item) => {
          return item.set(criterion.keyName, criterion.text);
        })
    })
  }

  handleRemoveCriteria(id){
    let criteriaIndex =  this.state.criteria.findIndex((s) => s.get('id') === id);
    this.setState({
      criteria: this.state.criteria.delete(criteriaIndex)
    })
  }

  handleUpdateRubricLocal(rubric){
    if(rubric.criteria){
      this.setState({
        rubric_id: rubric.id,
        criteria: Immutable.fromJS(rubric.criteria)
      })
    }else {
      this.state.rubric_id = rubric.id;
    }
  }

  handleUpdateRubric(){
    this.setState({
      rubric_id: null,
      criteria: Immutable.fromJS([])
    })
  }

  handleFetchRubric(){
    this.setState({
      rubric_id: null,
      criteria: Immutable.fromJS([])
    })
  }

  handleToggleEditMode(condition){
    this.state.editMode = condition;
  }
}
module.exports = alt.createStore(ImmutableStore(RubricStore));
