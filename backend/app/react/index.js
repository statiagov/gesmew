window.React = require('react');

import InspectionScopeShow from './components/inspection/scope-show';
import InspectionSelectDate from './components/inspection/select-date';
import GesmewRubricAssessmentApp from './gesmew_rubric_assessment/components/main';

registerComponent('inspection-scope-show', InspectionScopeShow);
registerComponent('gesmew-rubric-assement-app',GesmewRubricAssessmentApp);
registerComponent('inspection-select-date',InspectionSelectDate);
