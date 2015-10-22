import React from 'react';
import axios from 'axios';

class ScopeShow extends React.Component {
  render() {
    var action;
    if(this.props.status === 'pending'){
      action = <a className="btn btn-danger btn-sm icon-link with-tip action-delete no-text" onClick={this.onClick.bind(this)} href="#">
        <span className="icon icon-delete"></span>
      </a>;
    }
    else{
      action = <span className="icon icon-ok"></span>;
    }

    return (
      <div className="panel panel-default">
        <div className="panel-heading">
          <h1 className="panel-title">
            {Gesmew.translations.scope}
          </h1>
        </div>
        <table className="table table-bordered inspectors">
          <thead>
            <th colSpan="1">{Gesmew.translations.name}</th>
            <th className="text-center">{Gesmew.translations.description}</th>
            <th className="inspections-actions text-center"></th>
          </thead>
          <tbody>
            <tr className="inspector">
              <td className="text-center">
                {this.props.scope.name}
              </td>
              <td className="text-center">
                {this.props.scope.description}
              </td>
              <td className="inspector-actions actions-4 text-center">
                {action}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }

  onClick(e){
    e.preventDefault();
    if(this.props.status === 'pending'){
      axios.delete(`${Gesmew.routes.inspections_api}/${inspection_number}/scopes/${this.props.scope.id}`,{
        token: Gesmew.api_key
      }).then(()=>{
        window.location.reload(true);
      }).catch((r)=>{
        console.log(r);
      })
    }
  }
}

export default ScopeShow;
