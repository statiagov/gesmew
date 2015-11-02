import React from 'react';
import Cell from './Cell';
import connectToStores  from 'alt/utils/connectToStores';
import RubricAssessmentStore from '../stores/RubricAssessmentStore';
import RubricAssessmentActions from '../actions/RubricAssessmentActions';
import uniqueId from  'uniqueid';
import Immutable from 'immutable';
import validator from 'validator';

@connectToStores
export default class Main extends React.Component {

  constructor(props){
    super(props)
  }

  static getStores(){
    return [RubricAssessmentStore];
  }

  static getPropsFromStores(){
    return RubricAssessmentStore.getState();
  }

  componentDidMount(){
    RubricAssessmentStore.listen(this.onChange.bind(this));
    setTimeout(()=>{
      RubricAssessmentActions.loadAssessment(this.props.assessment);
    },100)

  }

  componentWillUnmount(){
    RubricAssessmentStore.unlisten(this.onChange.bind(this));
  }

  onChange(state){
    this.setState(state);
  }

  render() {
    return (
      <div className="panel panel-default">
        <div className="panel-heading clearfix">
          <h1 className="panel-title">Rubric</h1>
        </div>
        <table className="table table-bordered">
          <thead>
            <th className="text-center">Criteria</th>
            <th className="text-center">Description</th>
            <th className="text-center">Pts</th>
          </thead>
          <tbody>
            {this.props.criteria.map((c) => {
              return (
                <tr key={c.get('id')}>
                  <td>{c.get('name')}</td>
                  <td>{c.get('description')}</td>
                  <Cell
                    keyName="points"
                    id={c.get('id')}
                    validator={validator.isFloat}
                    score={c.get('score')}
                    points={c.get('points')}
                  />
                </tr>
              )
            })}
            <tr>
              <td colSpan="3">
                <div className="pull-right">
                  Total Score: {RubricAssessmentStore.getScoreTotal()} pts
                </div>
                <div className="pull-left">
                  <a href="#" onClick={this.saveRubric.bind(this)} className="btn btn-success btn-sm">Save</a>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }

  saveRubric(e){
    e.preventDefault();
    var params = {
      criteria: this.state.criteria.toJS()
    }
    RubricAssessmentActions.saveAssessment(params)
  }

}
