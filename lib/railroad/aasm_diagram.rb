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
    return unless current_class.respond_to?('states')
    
    node_attribs = []
    node_type = 'aasm'
    
    current_class.states.each do |state_name|
      state = current_class.read_inheritable_attribute(:states)[state_name]
      node_shape = (current_class.initial_state === state_name) ? ", peripheries = 2" : ""
      node_attribs << "#{current_class.name.downcase}_#{state_name} [label=#{state_name} #{node_shape}];"
    end
    @graph.add_node [node_type, current_class.name, node_attribs]
    
    current_class.read_inheritable_attribute(:transition_table).each do |event_name, event|
      event.each do |transition|
        @graph.add_edge [
          'event', 
          current_class.name.downcase + "_" + transition.from.to_s, 
          current_class.name.downcase + "_" + transition.to.to_s, 
          event_name.to_s
        ]
      end
    end
  end
end
