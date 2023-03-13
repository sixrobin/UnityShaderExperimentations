// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Wiggle" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_amplitudeX("Amplitude X", float) = 5
		_amplitudeY("Amplitude Y", float) = 5
		_distortionX("Distortion X", float) = 2
		_distortionY("Distortion Y", float) = 2
		_speed("Speed", float) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos	: SV_POSITION;
		float2 uv	: TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _amplitudeX;
	float _amplitudeY;
	float _distortionX;
	float _distortionY;
	float _timer;
	float _speed;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float rand()
	{
		return (sin(dot(-0.1, 0.1)));
	}

	float4 frag(v2f i) : SV_Target 
	{
		float2 uv = (float2)0;
		uv = i.uv;

		uv.x += sin(_Time.z * _speed + uv.x * _amplitudeX) * _distortionX * rand();
	    uv.y += sin(_Time.z * _speed + uv.y * _amplitudeY) * _distortionY * rand();

	    return tex2D(_MainTex, uv);
	}

	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			ENDCG
		}
	}
}
