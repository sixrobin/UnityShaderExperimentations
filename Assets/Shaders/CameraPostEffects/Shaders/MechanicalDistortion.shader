// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/MechanicalDistortion" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_normaMap("NormalMap", 2D) = "" {}
		_speedX("Horizontal Speed", float) = 0
		_speedY("Vertical Speed", float) = 0
		_strength("Strength", float) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos	: SV_POSITION;
		float2 uv	: TEXCOORD0;
	};
	
	sampler2D _MainTex;
	sampler2D _normalMap;
	float _speedX;
	float _speedY;
	float _strength;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float2 base = (float2)0;
		base.x = i.uv.x - _strength/100 * _Time.z * _speedX;
		base.y = i.uv.y - _strength/100 * _Time.z * _speedY;

	    float2 nm = tex2D(_normalMap, base).rgb;
	    base.x = (i.uv.x + nm.x * _strength/1000);
	    base.y = (i.uv.y + nm.y * _strength/1000);

	    return fixed4(tex2D(_MainTex, base * (1 - nm * _strength/100)).rgb, 1.0f);
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
			ENDCG
		}  
	}
	Fallback off	
}
