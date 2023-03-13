// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Grayscale" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	uniform sampler2D _MainTex;

	v2f vert(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	float4 frag(v2f_img i) : COLOR
	{
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		float gs = (float)0;
		gs = dot(float3(0.33, 0.33, 0.33), sum.rgb);

		return fixed(gs);
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
