// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Glow" {

	Properties
	{
		_MainTex("base", 2D) = "white" {}
		_exposure("Exposure", float) = 0.5
		_bright("Maximum Bright", float) = 0.5
		_global("Global Luminance", float) = 0.5
		_intensity("Glow Intensity", float) = 2
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _exposure;
	float _bright;
	float _global;
	float _intensity;

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
		float ratio = 128;

		float3 o00 = tex2D(_MainTex, i.uv - float2(3, 3) / (ratio * _intensity)).rgb;
		float3 o10 = tex2D(_MainTex, i.uv - float2(2, 3) / (ratio * _intensity)).rgb;
		float3 o20 = tex2D(_MainTex, i.uv - float2(1, 3) / (ratio * _intensity)).rgb;
		float3 o30 = tex2D(_MainTex, i.uv - float2(0, 3) / (ratio * _intensity)).rgb;
		float3 o40 = tex2D(_MainTex, i.uv - float2(-1, 3) / (ratio * _intensity)).rgb;
		float3 o50 = tex2D(_MainTex, i.uv - float2(-2, 3) / (ratio * _intensity)).rgb;
		float3 o60 = tex2D(_MainTex, i.uv - float2(-3, 3) / (ratio * _intensity)).rgb;

		float3 o01 = tex2D(_MainTex, i.uv - float2(3, 2) / (ratio * _intensity)).rgb;
		float3 o11 = tex2D(_MainTex, i.uv - float2(2, 2) / (ratio * _intensity)).rgb;
		float3 o21 = tex2D(_MainTex, i.uv - float2(1, 2) / (ratio * _intensity)).rgb;
		float3 o31 = tex2D(_MainTex, i.uv - float2(0, 2) / (ratio * _intensity)).rgb;
		float3 o41 = tex2D(_MainTex, i.uv - float2(-1, 2) / (ratio * _intensity)).rgb;
		float3 o51 = tex2D(_MainTex, i.uv - float2(-2, 2) / (ratio * _intensity)).rgb;
		float3 o61 = tex2D(_MainTex, i.uv - float2(-3, 2) / (ratio * _intensity)).rgb;

		float3 o02 = tex2D(_MainTex, i.uv - float2(3, 1) / (ratio * _intensity)).rgb;
		float3 o12 = tex2D(_MainTex, i.uv - float2(2, 1) / (ratio * _intensity)).rgb;
		float3 o22 = tex2D(_MainTex, i.uv - float2(1, 1) / (ratio * _intensity)).rgb;
		float3 o32 = tex2D(_MainTex, i.uv - float2(0, 1) / (ratio * _intensity)).rgb;
		float3 o42 = tex2D(_MainTex, i.uv - float2(-1, 1) / (ratio * _intensity)).rgb;
		float3 o52 = tex2D(_MainTex, i.uv - float2(-2, 1) / (ratio * _intensity)).rgb;
		float3 o62 = tex2D(_MainTex, i.uv - float2(-3, 1) / (ratio * _intensity)).rgb;

		float3 o03 = tex2D(_MainTex, i.uv - float2(3, 0) / (ratio * _intensity)).rgb;
		float3 o13 = tex2D(_MainTex, i.uv - float2(2, 0) / (ratio * _intensity)).rgb;
		float3 o23 = tex2D(_MainTex, i.uv - float2(1, 0) / (ratio * _intensity)).rgb;
		float3 o33 = tex2D(_MainTex, i.uv).rgb;
		float3 o43 = tex2D(_MainTex, i.uv - float2(-1, 0) / (ratio * _intensity)).rgb;
		float3 o53 = tex2D(_MainTex, i.uv - float2(-2, 0) / (ratio * _intensity)).rgb;
		float3 o63 = tex2D(_MainTex, i.uv - float2(-3, 0) / (ratio * _intensity)).rgb;

		float3 o04 = tex2D(_MainTex, i.uv - float2(3, -1) / (ratio * _intensity)).rgb;
		float3 o14 = tex2D(_MainTex, i.uv - float2(2, -1) / (ratio * _intensity)).rgb;
		float3 o24 = tex2D(_MainTex, i.uv - float2(1, -1) / (ratio * _intensity)).rgb;
		float3 o34 = tex2D(_MainTex, i.uv - float2(0, -1) / (ratio * _intensity)).rgb;
		float3 o44 = tex2D(_MainTex, i.uv - float2(-1, -1) / (ratio * _intensity)).rgb;
		float3 o54 = tex2D(_MainTex, i.uv - float2(-2, -1) / (ratio * _intensity)).rgb;
		float3 o64 = tex2D(_MainTex, i.uv - float2(-3, -1) / (ratio * _intensity)).rgb;

		float3 o05 = tex2D(_MainTex, i.uv - float2(3, -2) / (ratio * _intensity)).rgb;
		float3 o15 = tex2D(_MainTex, i.uv - float2(2, -2) / (ratio * _intensity)).rgb;
		float3 o25 = tex2D(_MainTex, i.uv - float2(1, -2) / (ratio * _intensity)).rgb;
		float3 o35 = tex2D(_MainTex, i.uv - float2(0, -2) / (ratio * _intensity)).rgb;
		float3 o45 = tex2D(_MainTex, i.uv - float2(-1, -2) / (ratio * _intensity)).rgb;
		float3 o55 = tex2D(_MainTex, i.uv - float2(-2, -2) / (ratio * _intensity)).rgb;
		float3 o65 = tex2D(_MainTex, i.uv - float2(-3, -2) / (ratio * _intensity)).rgb;

		float3 o06 = tex2D(_MainTex, i.uv - float2(3, -3) / (ratio * _intensity)).rgb;
		float3 o16 = tex2D(_MainTex, i.uv - float2(2, -3) / (ratio * _intensity)).rgb;
		float3 o26 = tex2D(_MainTex, i.uv - float2(1, -3) / (ratio * _intensity)).rgb;
		float3 o36 = tex2D(_MainTex, i.uv - float2(0, -3) / (ratio * _intensity)).rgb;
		float3 o46 = tex2D(_MainTex, i.uv - float2(-1, -3) / (ratio * _intensity)).rgb;
		float3 o56 = tex2D(_MainTex, i.uv - float2(-2, -3) / (ratio * _intensity)).rgb;
		float3 o66 = tex2D(_MainTex, i.uv - float2(-3, -3) / (ratio * _intensity)).rgb;
		
		float3 sum = (float3)0;
		sum += (o00 + o60 + o06 + o66);
		sum += 2 * (o10 + o50 + o15 + o56 + o65 + o01 + o05 + o16);
		sum += 6 * (o20 + o11 + o02 + o40 + o51 + o62 + o04 + o15 + o26 + o64 + o55 + o46);
		sum += 14 * (o30 + o03 + o63 + o36);
		sum += 24 * (o21 + o12 + o41 + o52 + o14 + o25 + o54 + o45);
		sum += 32 * (o31 + o13 + o53 + o35);
		sum += 54 * (o22 + o42 + o24 + o44);
		sum += 67 * (o32 + o23 + o43 + o34);
		sum += 80 * o33;
		sum /= (ratio * _intensity);
		
		float hdr = _exposure * (_exposure / _bright + 1) / (_exposure + 1);
		sum = o33 + sum * (_global)* _global;

		return fixed4(sum, 1) * hdr;
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
			ENDCG
		}
	}
}
