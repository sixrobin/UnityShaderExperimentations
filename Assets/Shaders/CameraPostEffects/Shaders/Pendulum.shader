// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Pendulum" {

	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_speed("Speed", float) = 1
		_aberration("Aberration Amplitude", float) = 0
	}
		
	CGINCLUDE
	#include "UnityCG.cginc"
		
	sampler2D _MainTex;
	float _speed;
	float _aberration;
	float4 _MainTex_ST;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_full v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	float4 frag(v2f i) :COLOR
	{
		float2 fx = i.uv + float2(sin(i.uv.y * 3.1416 / 2) * sin(_Time.z * _speed * 2) / 10, 0);
		float4 sum = tex2D(_MainTex, fx);
		float4 aberration = tex2D(_MainTex, fx + float2(sin(_Time.z * _speed * 2) / 100 * _aberration, 0));

		return fixed4(sum.r, aberration.g, sum.b, 1);
	}
		
	ENDCG

	SubShader 
	{
		pass 
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
}