import UnityEngine

class Player2 (MonoBehaviour): 
	
	public phase_thresh as single = 0.8
	
	public other as GameObject

	public weightDisplay as GUIText

	grounded = false
	private attacked as bool = false
	
	//The animator
	private anim as Animator
	
	//HashID
	private walkingState as int
	private jumpState as int

	def Start ():
		walkingState = Animator.StringToHash('Walk')
		jumpState = Animator.StringToHash('Jump')
		anim = GetComponent[of Animator]()
		
		if GetComponent(Attacked)!=null:
			attacked = true
	
	public static holding as GameObject = null

	#enable/disable the collider and render of an object AND all its children
	# (in particular, the foot trigger child)
	def switch_states(gameObject as GameObject, isActive as bool):
		if (gameObject.renderer):
			gameObject.renderer.enabled = isActive
		if (gameObject.collider):
			gameObject.collider.enabled = isActive

		for  child  as Transform in gameObject.transform:
				switch_states(child.gameObject, isActive)


	def GetPhase():
		return other.GetComponent(Player).GetPhase()
	
	def Update ():
		current_phase = other.GetComponent(Player).GetPhase()
		rigidbody.mass = 1.01 - current_phase

		#Phase in and out of existence.
		if current_phase == 1:
			if holding != null:
				holding.GetComponent[of Pickup2]().Drop()
			switch_states(gameObject, false)
			renderer.material.color.a = 0
		else:
			switch_states(gameObject, true)
			if current_phase == 0.5: renderer.material.color.a = 0.5
			else: renderer.material.color.a = 1
		
		if not attacked or not GetComponent(Attacked).isStunned():
			
			if Input.GetAxis("Horizontal") < 0:
				if Mathf.Round(transform.eulerAngles.y) != 270:
					transform.eulerAngles.y = Mathf.Round(transform.eulerAngles.y-10)
			elif Input.GetAxis("Horizontal") > 0:
				if Mathf.Round(transform.eulerAngles.y) != 90:
					transform.eulerAngles.y = Mathf.Round(transform.eulerAngles.y+10)
					
			if holding == null:
				if Physics.Raycast(transform.position + Vector3(0, -0.9, 0), Vector3.right * Input.GetAxis("Horizontal"), 0.7, ~(1 << 8)) == false:
					if Physics.Raycast(transform.position + Vector3(0, 0.9, 0), Vector3.right * Input.GetAxis("Horizontal"), 0.7, ~(1 << 8)) == false:
						if Physics.Raycast(transform.position, Vector3.right * Input.GetAxis("Horizontal"), 0.7, ~(1 << 8)) == false:
							transform.position.x += Input.GetAxis("Horizontal") * Player.speed * Time.deltaTime
							anim.SetBool(walkingState, true)
						else:
							anim.SetBool(walkingState, false)
					else:
						anim.SetBool(walkingState, false)
				else:
					anim.SetBool(walkingState, false)
			else:
				if Physics.Raycast(transform.position + Vector3(0, -0.9, 0), Vector3.right * Input.GetAxis("Horizontal"), 0.7, ~(1 << 8)) == false:
					if Input.GetAxis("Horizontal") > 0:
						x = 1.5
					else:
						x = -1.5
					if Physics.Raycast(transform.position + Vector3(x, 1.3, 0), Vector3.right * Input.GetAxis("Horizontal"), 1.5, ~(1 << 8)) == false:
						if Physics.Raycast(transform.position, Vector3.right * Input.GetAxis("Horizontal"), 0.7, ~(1 << 8)) == false:
							transform.position.x += Input.GetAxis("Horizontal") * Player.speed * Time.deltaTime
							anim.SetBool(walkingState, true)
						else:
							anim.SetBool(walkingState, false)
					else:
						anim.SetBool(walkingState, false)
				else:
					anim.SetBool(walkingState, false)
						
			if grounded:
				
				if Input.GetButtonDown("Jump"):
					anim.SetBool(jumpState, true)
					rigidbody.velocity.y = Player.jump_speed
				else:
					anim.SetBool(jumpState, false)

		weightDisplay.text = "Weight: " + Mathf.Round(((current_phase-1)/2) * -100.0) +"%"
			
			
		if Input.GetButtonDown('Pickup2'):
			if holding == null:
				nearest = GetNearestTagged()
				if nearest != null:
					nearest.GetComponent[of Pickup2]().PickUp()
			else:
				holding.GetComponent[of Pickup2]().Drop()

	def OnMouseDown():
		
		if holding != null:
			holding.GetComponent[of Pickup2]().Drop()
			
	def OnTriggerStay(other as Collider):
		
		if other.CompareTag("Player") == false:
			grounded = true
			
	def OnTriggerExit(other as Collider):
		
		grounded = false
			
	def GetNearestTagged() as GameObject:
        Tagged as (GameObject)= GameObject.FindGameObjectsWithTag('Pickup2')
        closest as GameObject
        distance as single = Mathf.Infinity
        position as Vector3 = transform.position
        
        for obj as GameObject in Tagged:
            difference as Vector3 = (obj.transform.position - position)
            curDistance as single = difference.sqrMagnitude
            if curDistance < distance:
                closest = obj
                distance = curDistance
        return closest
