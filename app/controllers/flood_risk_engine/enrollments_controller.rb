require_dependency "flood_risk_engine/application_controller"

module FloodRiskEngine
  class EnrollmentsController < ApplicationController
    def new
      enrollment = Enrollment.create
      # TODO: make first step come from state_machine
      url = enrollment_step_path(enrollment, enrollment.initial_step)
      redirect_to url
    end
  end
end