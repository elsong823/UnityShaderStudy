Shader "MyShader/c7/worldNormalMap"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 20
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

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 t2w_1 : TEXCOORD1;
				float4 t2w_2 : TEXCOORD2;
				float4 t2w_3 : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = TRANSFORM_TEX(i.texcoord, _BumpMap);

				float3 worldNormal = UnityObjectToWorldNormal( i.normal );
				float3 worldTangent = UnityObjectToWorldDir( i.tangent.xyz );
				float3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w;
				float3 worldFragPos = mul(_Object2World, i.vertex).xyz;

				o.t2w_1 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldFragPos.x);
				o.t2w_2 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldFragPos.y);
				o.t2w_3 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldFragPos.z);

//				o.t2w_1 = float4(worldTangent.xyz, worldFragPos.x);
//				o.t2w_2 = float4(worldBinormal.xyz, worldFragPos.y);
//				o.t2w_3 = float4(worldNormal.xyz, worldFragPos.z);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
//				float3x3 matV2W = float3x3(i.t2w_1.xyz,i.t2w_2.xyz,i.t2w_3.xyz);
				float3 worldFragPos = float3(i.t2w_1.w, i.t2w_2.w, i.t2w_3.w);
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir(worldFragPos) );
				fixed3 worldView = normalize( UnityWorldSpaceViewDir(worldFragPos) );
				//calc normal
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 worldNormal = UnpackNormal( packedNormal );
				worldNormal.xy *= _BumpScale;
				worldNormal.z = sqrt(1.0 - saturate( dot(worldNormal.xy, worldNormal.xy) ));
				worldNormal = normalize(half3(dot(i.t2w_1.xyz, worldNormal), dot(i.t2w_2.xyz, worldNormal), dot(i.t2w_3.xyz, worldNormal)));
//				worldNormal = normalize( mul(worldNormal, matV2W) );
				fixed3 worldHalf = normalize(worldLight + worldView);
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate( dot(worldLight, worldNormal) );

				fixed3 specular = _LightColor0 * _Specular * pow(saturate( dot(worldHalf, worldNormal) ), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}