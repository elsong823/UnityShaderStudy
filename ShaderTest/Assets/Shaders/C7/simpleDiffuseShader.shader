Shader "MyShader/c7/simpleDiffuseShader"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 worldNormal : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
			};

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.worldNormal.xyz = mul(i.normal, (float3x3)_World2Object);
				o.worldPos.xyz = mul(_Object2World, i.vertex).xyz;

				//calc uv
				o.worldNormal.w = i.texcoord.x * _MainTex_ST.x + _MainTex_ST.z;
				o.worldPos.w = i.texcoord.y * _MainTex_ST.y + _MainTex_ST.w;
				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize( _WorldSpaceLightPos0 );
				fixed3 worldView = normalize( _WorldSpaceCameraPos.xyz - i.worldPos.xyz );
				fixed3 worldHalf = normalize( worldLight + worldView );

				fixed3 albedo = tex2D(_MainTex, fixed2(i.worldNormal.w, i.worldPos.w)).rgb * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate( dot(worldLight, worldNormal) );
//				fixed3 diffuse = albedo * (dot(worldNormal, worldLight) * 0.5 + 0.5);
				return fixed4(ambient + diffuse, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}