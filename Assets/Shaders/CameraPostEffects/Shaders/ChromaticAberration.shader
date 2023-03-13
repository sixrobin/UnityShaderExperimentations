// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/ChromaticAberration" {

	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_chromaticAberration("Chromatic Aberration", float) = 0.5
		_centerX("Epicenter X", float) = 0.5
		_centerY("Epicenter Y", float) = 0.5
	}
			
	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata 
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f 
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float _chromaticAberration;
	float _centerX;
	float _centerY;

	v2f vert(appdata v) 
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		float2 rectangle = float2(i.uv.x - _centerX, i.uv.y - _centerY);
		float dist = sqrt(pow(rectangle.x, 2) + pow(rectangle.y, 2));

		float mov = _chromaticAberration * dist;
		float2 uvR = float2(i.uv.x - mov, i.uv.y);
		float2 uvG = float2(i.uv.x + mov, i.uv.y);
		float2 uvB = float2(i.uv.x, i.uv.y - mov);

		float4 colR = tex2D(_MainTex, uvR);
		float4 colG = tex2D(_MainTex, uvG);
		float4 colB = tex2D(_MainTex, uvB);

		return fixed4(colR.r, colG.g, colB.b, 0.77f);
	}

	ENDCG

	SubShader 
	{
		Pass
		{
			Cull off
			Blend srcAlpha 
			OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback off
}
