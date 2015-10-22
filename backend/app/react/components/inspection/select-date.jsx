require('react-date-picker/base.css');
require('react-date-picker/theme/hackerone.css');
import React from 'react';
import axios from 'axios';
import moment from 'moment';
import DatePicker from 'react-date-picker';

class SelectDate extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      date: this.props.date,
      shown:false
    }
  }

  render() {
    var datePickerHtml;
    if(this.state.shown){
      datePickerHtml = <DatePicker
        date={this.state.date}
        onChange={this.onChange.bind(this)}
      />;
    }else{
      datePickerHtml = null;
    }

    return (
      <div className="panel panel-default">
        <div className="panel-heading">
          <h1 className="panel-title">{Gesmew.translations.inspection_date}</h1>
        </div>
        <div className="panel-body">
          <div className="form-group">
            <label style={{cursor: "pointer", cursor: "hand"}} htmlFor="inspected_at">
              {Gesmew.translations.select_date_of_inspection}.</label>
            <input type="text" onClick={this.toggleDatePicker.bind(this)} className="datepicker-from form-control" value={this.formatDate(this.state.date)}/>
            {datePickerHtml}
          </div>
        </div>
      </div>
    )
  }

  formatDate(date){
    return moment(date).format("dddd, MMMM Do YYYY")
  }

  toggleDatePicker(e){
    e.preventDefault();
    var shown = !this.state.shown;
    this.setState({shown:shown});
  }

  onChange(date){
    if(this.props.status !== 'completed'){
      axios.put(`${Gesmew.routes.inspections_api}/${inspection_number}`,{
        token: Gesmew.api_key,
        inspection:{
          inspected_at: date
        }
      }).then(()=>{
        this.setState({date:date})
      }).catch((r)=>{
        console.log(r);
      })
    }
  }
}

export default SelectDate;
