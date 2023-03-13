// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Fisheye" {

	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_intensityX("Intensity X", float) = 0.25
		_intensityY("Intensity Y", float) = 0.25
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	fixed4 _MainTex_ST;
	float _intensityX;
	float _intensityY;

	struct v2f
	{
		fixed4 pos : SV_POSITION;
		fixed2 uv : TEXCOORD0;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) :COLOR
	{		
		float2	ooo = (i.uv - 0.5) * 2.0;

		float2 uv;
		uv.x = (1 - ooo.y * ooo.y) * sqrt(_intensityX) * ooo.x;
		uv.y = (1 - ooo.x * ooo.x) * sqrt(_intensityY) * ooo.y;

		float4 sum = tex2D(_MainTex, i.uv - uv);

		return fixed4(sum);
	}
	
	ENDCG
					
	SubShader 
	{
		pass 
		{
			Tags{ "LightMode" = "ForwardBase" }
			Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			ENDCG
		}
	}
	Fallback off
}
