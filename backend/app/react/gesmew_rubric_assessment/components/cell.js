import React from 'react';
import RubricAssessmentActions from '../actions/RubricAssessmentActions'
import validator from 'validator';

export default class Cell extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      text: this.props.score
    }
  }

  static defaultProps = {
    cellLength:2,
    validator: validator.sAscii
  }

  render(){

    var editLinkStyle = {
      float: "right",
      marginBottom:"10px"
    }

    return (
      <td height="50px">
        <div className="col-xs-5 pull-left" style={{paddingRight:"1px"}}>
          <input ref="score_input" className="form-control" value={this.state.text}  type="text" onFocus={this.handleFocus}  onChange={this.onChange.bind(this)}/>
        </div>
        <div className="line"></div>
        <span style={{marginBottom:"5"}}>
          <strong>{this.props.points}</strong>
        </span>
      </td>
    )
  }


  onChange(event) {
    var value = event.target.value

    if(this.props.validator(value)){
      if(value < this.props.points && value > -1) {
        this.setState({text: value}, ()=>{
          this.updateScore()
        })
      }
      else {
        this.setState({text:this.props.points},()=>{
          this.updateScore()
        })
      }
    }
    else {
      this.setState({text:''}, ()=>{
        this.updateScore()
      })
    }
  }

  handleFocus(e) {
    e.target.select();
  }

  updateScore(){
    RubricAssessmentActions.updateScore({
      id: this.props.id,
      score: this.state.text
    })
  }

  focus(){
    if (this.state.editing == true) {
      this.refs.score_input.getDOMNode().focus();
    }
  }

  toggleEditing(toggled, e){
    e.preventDefault();
    this.setState({editing:toggled}, () =>{
      this.focus();
    });
  }
}
