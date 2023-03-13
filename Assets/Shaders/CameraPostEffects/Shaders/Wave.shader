// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Wave" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_frequencyX("Horizontal Strength", float) = 1
		_frequencyY("Vertical Strength", float) = 1
		_amplitudeX("X Axis Amplitude", float) = 0.5
		_amplitudeY("Y Axis Amplitude", float) = -0.5
		_speed("Time Controller", float) = 1
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos	: SV_POSITION;
		float2 uv	: TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _frequencyX;
	float _frequencyY;
	float _amplitudeX;
	float _amplitudeY;
	float _speed;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float2 wave;
		float coef = 10;

		wave.x = i.uv.x + (sin((i.uv.y * _frequencyX * coef) + _Time.z * _speed) * _amplitudeY/coef);
		wave.y = i.uv.y + (sin((i.uv.x * _frequencyY * coef) + _Time.z * _speed) * _amplitudeX/coef);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, wave);

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
