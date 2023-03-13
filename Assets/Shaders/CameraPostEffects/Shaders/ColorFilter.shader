// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/ColorFilter" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_color("Color Filter", float) = 0
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	float4 _color;

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

		float gray = (float)0;
		gray = dot(float3(0.33, 0.33, 0.33), sum.rgb);

		float4 filter = (float)4;
		filter = _color/10;
		filter += gray;

		return fixed4(filter);
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
