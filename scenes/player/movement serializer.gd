extends "res://addons/delta_rollback/MessageSerializer.gd"

const input_path_mapping := {
	'/root/Game/SubViewportContainer/SubViewport/Player' : 1,
	'/root/Game/SubViewportContainer/SubViewport/Player2': 2,
	'/root/Game/SubViewportContainer/SubViewport/Player3': 3,
	'/root/Game/SubViewportContainer/SubViewport/Player4': 4
}

const input_path_mapping_reversed := {
	1 : '/root/Game/SubViewportContainer/SubViewport/Player',
	2 : '/root/Game/SubViewportContainer/SubViewport/Player2',
	3 : '/root/Game/SubViewportContainer/SubViewport/Player3',
	4 : '/root/Game/SubViewportContainer/SubViewport/Player4'
}

enum HeaderFlags{
	HAS_INPUT_VECTOR = 0x01,
	CAST_SPELL = 0x02,
	SELECT_SPELL = 0x04,
}

func serialize_input(all_input: Dictionary) -> PackedByteArray:
	#Setup buffer
	var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.resize(16)
	
	#Serialize input hash
	buffer.put_u32(all_input['$'])
	#Serialize input count. If this is zero, when we read the data we skip this message
	buffer.put_u8(all_input.size() -1)
	
	#This loop goes over all message packets that haven't been confirmed received by
	#the other clients you're connected to.
	for path in all_input:
		if path == '$': continue
		
		#Serialize path to node that is sending this message
		buffer.put_u8(input_path_mapping[path])
		
		var header := 0
		
		#Check if this message includes an input vector
		#if it does, update header
		#This is where we will say what inputs we will send. Later on we will
		#actually store the info below the header.
		var input = all_input[path]
		if input.has('input_vector'):
			header |= HeaderFlags.HAS_INPUT_VECTOR
		if input.has('cast_spell'):
			header |= HeaderFlags.CAST_SPELL
		if input.has('select_spell'):
			header |= HeaderFlags.SELECT_SPELL
		
		#Store the header for this message
		buffer.put_u8(header)
		
		#This is where we actually encode the information.
		if input.has('input_vector'):
			var input_vector : Vector2i = input['input_vector']
			buffer.put_8(input_vector.x)
			buffer.put_8(input_vector.y)
		if input.has('cast_spell'):
			var click_position : Vector2i = input['click_position']
			buffer.put_8(click_position.x)
			buffer.put_8(click_position.y)
		if input.has('select_spell'):
			buffer.put_8(input['spell_index'])
	#Output of buffer
	buffer.resize(buffer.get_position())
	return buffer.data_array

func unserialize_input(serialized: PackedByteArray) -> Dictionary:
	var buffer : StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var all_input : Dictionary = {}
	
	#Serialize Input Hash
	all_input['$'] = buffer.get_u32()
	
	#If there are no inputs this message, move on
	var input_count = buffer.get_u8()
	if input_count == 0:
		return all_input
	
	#Get path to node that this message used
	var path = input_path_mapping_reversed[buffer.get_u8()]
	var input := {}
	
	#Unserialize the input header, this tells us if the input message has an input vector or not.
	#This should be the only place we need to add info to add subsequent inputs.
	var header = buffer.get_u8()
	if header & HeaderFlags.HAS_INPUT_VECTOR:
		input["input_vector"] = Vector2i(buffer.get_8(), buffer.get_8())
	if header & HeaderFlags.CAST_SPELL:
		input["cast_spell"] = true
		input["click_position"] = Vector2i(buffer.get_8(), buffer.get_8())
	if header & HeaderFlags.SELECT_SPELL:
		input["select_spell"] = true
		input["spell_index"] = buffer.get_8()
	
	all_input[path] = input
	
	return all_input
