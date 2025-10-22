class_name BackgroundFader extends ColorRect

@export var fade_duration: float = 2.0

var mat: ShaderMaterial
var previous_tex: Texture2D

func _init():
	mat = material as ShaderMaterial

func fade_to(new_gradient_tex : GradientTexture2D):
	if (mat == null): _init()
	
	if previous_tex == null:
		previous_tex = new_gradient_tex
	
	mat.set_shader_parameter("grad_tex1", previous_tex)
	mat.set_shader_parameter("grad_tex2", new_gradient_tex)
	mat.set_shader_parameter("fade", 0.0)
	
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/fade", 1.0, fade_duration)
	tween.tween_callback(func(): previous_tex = new_gradient_tex)
