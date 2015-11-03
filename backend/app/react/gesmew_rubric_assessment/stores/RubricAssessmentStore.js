var alt = require('../alt');
var RubricAssessmentActions = require('../actions/RubricAssessmentActions');
var _ = require('lodash')
var Immutable = require('immutable');
var ImmutableStore = require('alt/utils/ImmutableUtil');

class RubricAssessmentStore {
  constructor(){
    this.state = {
      criteria: []
    }
    this.bindListeners({
      handleUpdateScore: RubricAssessmentActions.UPDATE_SCORE,
      handleFetchCriteria: RubricAssessmentActions.LOAD_ASSESSMENT
    });
  }

  static getPointTotal() {
    let arr = []
    this.state.criteria.map((c, index) =>{
      arr.push(c.get('points'));
    });
    return _.sum(arr);
  }

  static getScoreTotal() {
    let arr = []
    this.state.criteria.map((c, index) =>{
      arr.push(c.get('score'));
    });
    return _.sum(arr);
  }

  handleUpdateScore(criterion){
    let criteriaIndex =  this.state.criteria.findIndex((s) => s.get('id') === criterion.id);
    this.setState({
      criteria: this.state.criteria.update(criteriaIndex,
        (item) => {
          return item.set('score', criterion.score);
        })
    })
  }

  handleFetchCriteria(assessment){
    console.log(assessment)
    this.state.criteria = Immutable.fromJS(assessment.data)
  }

  handleToggleEditMode(condition){
    this.state.editMode = condition;
  }
}
module.exports = alt.createStore(ImmutableStore(RubricAssessmentStore));
