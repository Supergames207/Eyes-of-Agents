class_name AgentRecruiter extends Control

const agent_card_path := "res://Agents/AgentCard.tscn"

var agent_card : PackedScene = preload(agent_card_path)

@export var agent_slots := 4


func _ready() -> void:
    populate()

func populate() -> void:
    for k in get_children():
        k.queue_free()
    
    for k in range(agent_slots):
        var new : AgentCardUI = agent_card.instantiate()

        var random_agent := generate_random_agent()
        new.agent = random_agent

        get_node("PanelContainer/CenterContainer/AgentCardHolder").add_child(new)

func generate_random_agent() -> Agent:
    var new_agent := Agent.new()

    new_agent.name = RandomStrings.random_names.pick_random()

    return new_agent
