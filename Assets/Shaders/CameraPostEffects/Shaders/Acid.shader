// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Acid" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_strength("Deform Force", float) = 5
		_colorSpeed("Color Variation Speed", float) = 1
		_colorAmplitude("Color Variation Amplitude", float) = 2
		_speed("Time Controller", float) = 1
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _strength;
	float _colorSpeed;
	float _colorAmplitude;
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
		float2 uv = i.uv;
		uv.x += sin(_Time.z * _speed + uv.x * _strength * _strength) * 0.01;
	    uv.y += cos(_Time.z * _speed + uv.y * _strength * _strength) * 0.01;
	    
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, uv);

		float lum = dot(sum, float3(0.31, 0.59, 0.11));
		float saturation = cos(_Time.z * _colorSpeed * 0.4) * _colorAmplitude;
		sum = lerp(lum, sum, float4(1, saturation + 0.2, saturation + 0.3, 1));
			 	
		return fixed4(sum);
	}

	ENDCG 
	
	Subshader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			ENDCG
		} 
	}
	Fallback off	
}
