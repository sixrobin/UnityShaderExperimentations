Shader "MyShaders/Kaleidoscope" {

	Properties
	{
		_MainTex("-", 2D) = "" {}
		_segment("Divisor Value", float) = 6
		_strength("Movement Strength", float) = 2.5
		_speed("Time Controller", float) = 0.5
	}
		
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _segment;
	float _strength;
	float _speed;

	half4 frag(v2f_img i) : SV_Target
	{
		float2 screen = (float2)0;
		screen = i.uv - 0.5;

		float phi, rad = (float)0;
		phi = atan2(screen.y, screen.x);
		rad = sqrt(dot(screen, screen));

		phi = phi - _segment * floor(phi / _segment);
		phi = min(phi, _segment - phi);
#ifdef SIN_WAVE
		phi += _strength * _SinTime * 500 * _speed;
#else
		phi += _strength * _Time.z * 25 * _speed;
#endif
		float2 uv = (float2)0;
		uv = float2(cos(phi), sin(phi)) * rad + 0.5;
		uv = max(min(uv, 2.0 - uv), -uv);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, uv);
#ifdef INVERT
		sum = 1 - sum;
#endif		
		return fixed4(sum);
	}

	ENDCG
		
	SubShader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma shader_feature INVERT
			#pragma shader_feature SIN_WAVE
			ENDCG
		}
	}
}
