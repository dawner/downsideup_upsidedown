import UnityEngine

class Sway (MonoBehaviour): 
	public horForce as single = 300

	def OnCollisionEnter(col as Collision):
		if (col.transform.tag == "Player"):
			#phase = GameObject.Find("Player1").GetComponent(Player).GetPhase()
			#if phase in [1,-1]: 
			GameObject.Find("SoundEffects").GetComponent(SoundEffects).PlayChain(transform.position)
			rigidbody.AddForce(Vector3(Input.GetAxis("Horizontal") * horForce,0,0))
