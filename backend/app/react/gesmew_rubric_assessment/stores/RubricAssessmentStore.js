var alt = require('../alt');
var RubricAssessmentActions = require('../actions/RubricAssessmentActions');
var _ = require('lodash')
var Immutable = require('immutable');
var ImmutableStore = require('alt/utils/ImmutableUtil');

class RubricAssessmentStore {
  constructor(){
    this.state = {
      editMode:false,
      criteria: Immutable.fromJS([
        {id:1, name:'Mold', description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.", score: 0, points:10},
        {id:2, name:'Floor', description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero.", score: 0, points:5},
        {id:3, name:'Some other criteria', description:"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.", score: 0, points:5},
      ])
    }
    this.bindListeners({
      handleUpdateScore: RubricAssessmentActions.UPDATE_SCORE
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

  handleRemoveCriteria(id){
    if(this.state.criteria.size > 3) {
      let criteriaIndex =  this.state.criteria.findIndex((s) => s.get('id') === id);
      this.setState({
        criteria: this.state.criteria.delete(criteriaIndex)
      })
    }else {
      alert("A rubric needs at least three criteria")
    }
  }

  handleToggleEditMode(condition){
    this.state.editMode = condition;
  }
}
module.exports = alt.createStore(ImmutableStore(RubricAssessmentStore));
