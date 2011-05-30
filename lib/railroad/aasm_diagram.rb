# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

# AASM code provided by Ana Nelson (http://ananelson.com/)

require 'railroad/app_diagram'
require 'railroad/models_diagram_shared'

# Diagram for Acts As State Machine
class AasmDiagram < AppDiagram
  include ModelsDiagramShared

  def initialize(options)
    #options.exclude.map! {|e| e = "app/models/" + e}
    super options 
    @graph.diagram_type = 'Models'
    # Processed habtm associations
    @habtm = []
  end

  private
  
  # Process a model class
  def process_class(current_class)
    
    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose
    
    # Only interested in acts_as_state_machine models.
    return unless current_class.respond_to?(:aasm_states)
    
    node_attribs = []
    node_type = 'aasm'
    
    current_class.aasm_states.each do |state|
      node_shape = (current_class.aasm_initial_state === state.name) ? ", peripheries = 2" : ""
      node_attribs << "#{current_class.name.downcase}_#{state.name} [label=#{state.name} #{node_shape}];"
    end
    @graph.add_node [node_type, current_class.name, node_attribs]
 
    current_class.aasm_events.each do |event_name, event|
      event.instance_variable_get(:@transitions).each do |transition|
        @graph.add_edge [
          'event', 
          "#{current_class.name.downcase}_#{transition.from}", 
          "#{current_class.name.downcase}_#{transition.to}", 
          event_name.to_s
        ]
      end
    end
  end
end
