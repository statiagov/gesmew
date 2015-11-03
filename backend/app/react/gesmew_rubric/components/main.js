import React from 'react';
import Cell from './EditableCell';
import connectToStores  from 'alt/utils/connectToStores';
import RubricStore from '../stores/RubricStore';
import RubricActions from '../actions/RubricActions';
import uniqueId from  'uniqueid';
import Immutable from 'immutable';
import validator from 'validator';
import Spinner from 'react-spinkit';

@connectToStores
export default class Main extends React.Component {

  constructor(props){
    super(props)
  }

  static getStores(){
    return [RubricStore];
  }

  static getPropsFromStores(){
    return RubricStore.getState();
  }

  componentDidMount(){
    RubricStore.listen(this.onChange.bind(this));
    RubricActions.fetchRubric(this.props.id);
  }

  componentWillUnmount(){
    RubricStore.unlisten(this.onChange.bind(this));
  }

  onChange(state){
    this.setState(state, function(){
      if(state.criteria.size > 0){
        var ref = this.refs['cell'+state.criteria.last().get('id')];
        if (ref){
          ref.focus();
        }
      }
    });
  }

  render() {

    var deleteRowHeading;
    if(this.props.editMode == true) {
      deleteRowHeading = <th className="text-center"></th>
    }

    if (!this.props.rubric_id) {
      return (
        <Spinner spinnerName='double-bounce' />
      )
    }

    return (
      <div>
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
                  <Cell
                    editing={c.get('editing')}
                    ref={'cell'+c.get('id')}
                    keyName="name"
                    id={c.get('id')}
                    text={c.get('name')}
                    cellLength={4}
                  />
                  <Cell
                    keyName="description"
                    id={c.get('id')}
                    text={c.get('description')}
                    cellLength={6}
                  />
                  <Cell
                    keyName="points"
                    id={c.get('id')}
                    validator={validator.isFloat}
                    text={c.get('points')}
                  />
                  <td>
                    <a onClick={this.removeCriteria.bind(this, c.get('id'))} href="#">
                      <span className="glyphicon glyphicon-remove"></span>
                    </a>
                  </td>
                </tr>
              )
            })}
            <tr style={{marginTop:"0px", lineHeigh:"20px"}}>
              <td colSpan="4">
                <div style={{float:"left"}}>
                  <a onClick={this.addCriteria.bind(this, uniqueId({multiplier: 10}))} href="#"><i className="glyphicon glyphicon-plus"> </i>Add Criteria</a>
                </div>
                <div style={{float:"right"}}>
                  <span style={{paddingRight:"10px"}}>
                    Total Points: {RubricStore.getPointTotal()}
                  </span>
                </div>
              </td>
            </tr>
            {(()=> {
              switch(this.props.criteria.size > 0){
                case true:
                  return (
                    <tr>
                      <td colSpan="3">
                        <div className="pull-right">
                          <a href="#" onClick={this.updateRubric.bind(this)} className="btn btn-success btn-sm">Update Rubric</a>
                        </div>
                      </td>
                    </tr>
                  )
              }
            })()}
          </tbody>
        </table>
      </div>
    )
  }

  toggleEditMode(toggle, e){
    e.preventDefault();
    RubricActions.toggleEditMode(toggle)
  }

  addCriteria(id, e){
    e.preventDefault();
    let criteria = Immutable.fromJS({
      id:id,
      editing:true,
      name:'Criteria name',
      description:'Description of criteria',
      points:10
    });
    RubricActions.addCriteria(criteria);
  }

  removeCriteria(id, e){
    e.preventDefault();
    RubricActions.removeCriteria(id);
  }

  updateRubric(e){
    e.preventDefault();
    var params = {
      id: this.props.id,
      criteria: this.props.criteria.toJS()
    }
    RubricActions.updateRubric(params);
  }

}
