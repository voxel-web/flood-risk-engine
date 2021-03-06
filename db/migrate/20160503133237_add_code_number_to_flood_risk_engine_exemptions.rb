class AddCodeNumberToFloodRiskEngineExemptions < ActiveRecord::Migration
  def change
    add_column :flood_risk_engine_exemptions, :code_number, :integer

    add_index :flood_risk_engine_exemptions, :code_number, unique: true

    FloodRiskEngine::Exemption.all.each &:save
  end
end
