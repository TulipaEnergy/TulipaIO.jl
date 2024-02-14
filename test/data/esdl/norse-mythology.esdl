<?xml version='1.0' encoding='UTF-8'?>
<esdl:EnergySystem xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:esdl="http://www.tno.nl/esdl" description="" esdlVersion="v2303" name="Norse Mythology" version="6" id="d4643afe-3813-4981-8fcf-974ca7018b5b">
  <instance xsi:type="esdl:Instance" id="ad7d4261-f4f7-4c63-8935-8e26ebf09b2f" name="Main">
    <area xsi:type="esdl:Area" name="Iceland" id="83dfdeaf-f885-462a-ac24-d3d3118c8f15">
      <area xsi:type="esdl:Area" id="dd27f13b-6d1e-4532-9092-bf5240099570" name="Valhalla">
        <asset xsi:type="esdl:Export" power="120.0" name="Export_06ca" id="06ca24ec-77f5-44fe-be5a-bf2a059e8654">
          <geometry xsi:type="esdl:Point" lon="-20.901145935058597" lat="64.23429914733688"/>
          <port xsi:type="esdl:InPort" id="29ce99fd-0c4f-47ae-8e29-ab6c4041a400" name="In" connectedTo="dc76a962-0359-4f88-9774-054c81aa78f2"/>
        </asset>
        <asset xsi:type="esdl:Electrolyzer" name="Electrolyzer_41ac" power="80.0" technicalLifetime="2.0" id="41ac619a-f1c5-4d89-a6f7-e75a9783c189">
          <geometry xsi:type="esdl:Point" lon="-20.953330993652347" lat="64.2198191095311"/>
          <costInformation xsi:type="esdl:CostInformation" id="ef1036b1-0496-4503-a174-026b9169f98e">
            <investmentCosts xsi:type="esdl:SingleValue" id="78e6ccda-9b94-4e5a-a2bc-28e0ae50a51f" value="26.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="13b95d58-007b-4b0e-b358-782a24a9897b" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="0e94f850-fe14-42c2-996f-ad4f6dcc9b9a" value="62.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="567bbf5b-6606-42bb-a306-f24ffc052144" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="a439cb30-d40f-498b-b6a7-e0cfcbda0752" name="In" connectedTo="dc76a962-0359-4f88-9774-054c81aa78f2"/>
          <port xsi:type="esdl:OutPort" id="f4e1f65a-98bd-482c-8fd1-56cd70d4b515" name="Out" connectedTo="87d08281-78d2-40de-8da5-b0db15c03361"/>
        </asset>
        <asset xsi:type="esdl:GasStorage" maxDischargeRate="200.0" maxChargeRate="100.0" name="GasStorage_f713" fillLevel="500.0" capacity="1000.0" technicalLifetime="3.0" id="f7138a43-41d8-4fa7-9504-ed340bc5205e">
          <geometry xsi:type="esdl:Point" lon="-20.99349975585938" lat="64.21683259218487"/>
          <costInformation xsi:type="esdl:CostInformation" id="235ed47c-6a88-4d90-b10a-b4b0f7ab92ee">
            <investmentCosts xsi:type="esdl:SingleValue" id="41e539ad-dace-4098-ae50-6deb7e409afb" value="100.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="4467313f-fcf3-4049-9c2a-53fe870c499d" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="acbd2711-9014-4e6f-8462-34358e799cbf" value="50.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="1b85ef70-6b17-4fa2-8a4d-e26a80f47665" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="584e6bd3-36ac-4540-b7d1-c6280785b9b9" name="In" connectedTo="226ea9fb-b875-4091-b3e8-9d21786b30b7"/>
        </asset>
        <asset xsi:type="esdl:HeatPump" name="HeatPump_4b33" power="10.0" technicalLifetime="2.0" id="4b33f488-b157-411a-ab02-7a0d43c154a3">
          <geometry xsi:type="esdl:Point" lon="-20.88912963867188" lat="64.22728399302186"/>
          <costInformation xsi:type="esdl:CostInformation" id="acbf20d9-e15f-4b5b-ac0b-f1ebd44f1550">
            <investmentCosts xsi:type="esdl:SingleValue" id="467c3336-f052-44cf-8ac8-130c0d755d9c" value="16.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="9e0d5847-d565-461a-b7f6-65bb18cbf680" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="ef041594-ad92-4c87-9346-05511bd25db8" value="15.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="93a93849-da7a-4d75-9607-7a6c6edfbea1" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="2f90ec2a-9efc-4979-9d86-99202db07c29" name="In" connectedTo="dc76a962-0359-4f88-9774-054c81aa78f2"/>
          <port xsi:type="esdl:OutPort" id="bb1b80cd-bce7-467d-8e86-b8b0e8644ee6" name="Out" connectedTo="7cd2a9f9-da85-4a0f-9c66-89376480ae39"/>
          <port xsi:type="esdl:InPort" id="82d42ef9-7d32-4991-821c-62b03a751ccf" name="Waste heat inport" connectedTo="db89cb60-8609-4417-bdbe-a7704a734176"/>
        </asset>
        <asset xsi:type="esdl:FuelCell" name="FuelCell_9121" power="90.0" technicalLifetime="3.0" id="91218656-3706-403a-909c-f67d14f8b40c">
          <geometry xsi:type="esdl:Point" lon="-20.916252136230472" lat="64.20667602226591"/>
          <costInformation xsi:type="esdl:CostInformation" id="f4430dfa-b5e4-4491-971e-0a1276bb4428">
            <investmentCosts xsi:type="esdl:SingleValue" id="5be5a662-55ce-4117-bf12-1072a6c2972d" value="60.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="bbf2fac1-240f-49b2-b9fe-c9aa248f6237" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="e5e20c91-0a64-4d08-b724-815dfa04d475" value="55.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="1ebb56e6-eb1b-41d9-9ba1-f0aced6b2731" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="27e984b8-7414-46c7-9f73-5f089a3c7719" name="In" connectedTo="226ea9fb-b875-4091-b3e8-9d21786b30b7"/>
          <port xsi:type="esdl:OutPort" id="a02d8cc6-ea45-4bfe-91c0-1813995c5f34" name="E Out" connectedTo="5e71413e-6c3c-491f-9aef-f7702dffc477"/>
          <port xsi:type="esdl:OutPort" id="33e09eff-3a6f-4ba0-aa52-7d3595aef6f8" name="H Out" connectedTo="7cd2a9f9-da85-4a0f-9c66-89376480ae39"/>
        </asset>
        <asset xsi:type="esdl:PowerPlant" name="PowerPlant_7227" power="100.0" technicalLifetime="12.0" id="7227d20f-918c-4de1-b698-a40ba29e9bc7" type="COMBINED_CYCLE_GAS_TURBINE">
          <geometry xsi:type="esdl:Point" lon="-20.965690612792972" lat="64.22862745817535"/>
          <costInformation xsi:type="esdl:CostInformation" id="b9d6a549-1643-4364-81d3-f66f13d39f12">
            <investmentCosts xsi:type="esdl:SingleValue" id="bbd99afa-e6b8-43c5-938a-fe6a5de8a094" value="51.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="9919ad01-e8a3-4bdf-aedf-d3b699c195d9" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="2f08aa06-9279-4ba0-942a-b4696a56a186" value="55.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="a8cc8399-5739-42f0-af76-28eeaa493e2e" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="ec622226-8d89-4464-8147-c7eafea89ca5" name="In" connectedTo="34ffa8ad-f971-4c52-bd72-461841ffd549"/>
          <port xsi:type="esdl:OutPort" id="c0ad56e3-3a83-46e9-8d2e-43cbd02e08c9" name="Out" connectedTo="5e71413e-6c3c-491f-9aef-f7702dffc477"/>
        </asset>
        <asset xsi:type="esdl:ElectricityNetwork" name="ElectricityNetwork_be51" id="be51458b-218f-46cb-af0b-315fc879b0f0">
          <geometry xsi:type="esdl:Point" lon="-20.932731628417972" lat="64.23429914733688"/>
          <port xsi:type="esdl:InPort" id="5e71413e-6c3c-491f-9aef-f7702dffc477" name="In" connectedTo="dcf68219-bdf5-4e35-9053-8bbfbe8feee8 34823af7-a4d9-4ae5-a715-bbab03bea4ac a02d8cc6-ea45-4bfe-91c0-1813995c5f34 c0ad56e3-3a83-46e9-8d2e-43cbd02e08c9"/>
          <port xsi:type="esdl:OutPort" id="dc76a962-0359-4f88-9774-054c81aa78f2" name="Out" connectedTo="29ce99fd-0c4f-47ae-8e29-ab6c4041a400 a439cb30-d40f-498b-b6a7-e0cfcbda0752 2f90ec2a-9efc-4979-9d86-99202db07c29"/>
        </asset>
        <asset xsi:type="esdl:GasNetwork" name="Gas network" id="bbaf1227-a413-4017-8cf9-6462f1947084">
          <geometry xsi:type="esdl:Point" lon="-21.03469848632813" lat="64.22056568851187"/>
          <port xsi:type="esdl:InPort" id="7b132b24-fb51-45a5-b56a-9f80670eaac7" name="In" connectedTo="1453f4b9-67eb-40b9-ad5b-2e17f4424e15 6cfe90b8-2d51-4b3a-b2f4-cef6e0742250"/>
          <port xsi:type="esdl:OutPort" id="34ffa8ad-f971-4c52-bd72-461841ffd549" name="Out" connectedTo="ec622226-8d89-4464-8147-c7eafea89ca5 2582d2d0-24b7-4e82-a2df-d192cfe55fbe"/>
        </asset>
        <asset xsi:type="esdl:HeatNetwork" name="HeatNetwork_07de" id="07de2a53-5a92-4eb3-835a-d89fde7cadbe">
          <geometry xsi:type="esdl:Point" lon="-20.86750030517578" lat="64.20368808661304"/>
          <port xsi:type="esdl:InPort" id="7cd2a9f9-da85-4a0f-9c66-89376480ae39" name="In" connectedTo="bb1b80cd-bce7-467d-8e86-b8b0e8644ee6 33e09eff-3a6f-4ba0-aa52-7d3595aef6f8"/>
          <port xsi:type="esdl:OutPort" id="7a4a907e-331c-49e1-9630-75a50f5ce061" name="Out" connectedTo="08332a70-84ef-43bb-8619-a1805dd8a52f"/>
        </asset>
        <asset xsi:type="esdl:GasNetwork" name="Hydrogen network" id="649b8515-cf84-438d-8e74-1da6c5073b69">
          <geometry xsi:type="esdl:Point" lon="-20.973587036132812" lat="64.21011174971652"/>
          <port xsi:type="esdl:InPort" id="87d08281-78d2-40de-8da5-b0db15c03361" name="In" connectedTo="f4e1f65a-98bd-482c-8fd1-56cd70d4b515 832a041e-8e71-46bc-8945-69705d87ba0a"/>
          <port xsi:type="esdl:OutPort" id="226ea9fb-b875-4091-b3e8-9d21786b30b7" name="Out" connectedTo="584e6bd3-36ac-4540-b7d1-c6280785b9b9 27e984b8-7414-46c7-9f73-5f089a3c7719 509306f7-dd17-4597-8166-b7f8fa8854d0"/>
        </asset>
        <asset xsi:type="esdl:GasDemand" power="50.0" name="Hydrogen demand" id="45fa1a43-8943-4d8f-8eba-bafbae17f974">
          <geometry xsi:type="esdl:Point" lon="-20.97427368164063" lat="64.21952047229907"/>
          <port xsi:type="esdl:InPort" id="509306f7-dd17-4597-8166-b7f8fa8854d0" name="In" connectedTo="226ea9fb-b875-4091-b3e8-9d21786b30b7"/>
        </asset>
        <asset xsi:type="esdl:GasConversion" name="Hydrogen generator" power="100.0" technicalLifetime="5.0" id="05058aad-f87e-4207-9118-e005a62a4004">
          <geometry xsi:type="esdl:Point" lon="-21.01341247558594" lat="64.20772172357896"/>
          <costInformation xsi:type="esdl:CostInformation" id="500c86f2-be54-409a-8960-8316a8149dbf">
            <investmentCosts xsi:type="esdl:SingleValue" id="a192a369-b8f5-484d-b456-e051ae6002d1" value="188.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="761e8aca-5cd1-4271-ab6e-a3c0b772611d" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="46394d97-7bb1-4403-b18f-d668c3c7bf89" value="12.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="5b76b520-c0cc-4b31-83e3-51e17a450b4a" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="2582d2d0-24b7-4e82-a2df-d192cfe55fbe" name="In" connectedTo="34ffa8ad-f971-4c52-bd72-461841ffd549"/>
          <port xsi:type="esdl:OutPort" id="832a041e-8e71-46bc-8945-69705d87ba0a" name="Out" connectedTo="87d08281-78d2-40de-8da5-b0db15c03361"/>
        </asset>
        <asset xsi:type="esdl:HeatProducer" power="100.0" name="Waste heat" technicalLifetime="2.0" id="f1b99314-4b7c-4f6b-88f2-520f4617fcf6">
          <geometry xsi:type="esdl:Point" lon="-20.857200622558597" lat="64.22982159465025"/>
          <costInformation xsi:type="esdl:CostInformation" id="f1909582-03bf-4d08-8089-6b4c0548a741">
            <investmentCosts xsi:type="esdl:SingleValue" id="97abf1f5-2e52-4b9d-af64-6cc5266febfc" value="14.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="3638b024-9076-455c-9f4c-b1644ab99860" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="ef99b456-3431-49d2-9eb0-1bfd5f2d6c2a" value="2.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="986b29dc-081e-4ed5-9784-7d7d07ff2943" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:OutPort" id="db89cb60-8609-4417-bdbe-a7704a734176" name="Out" connectedTo="82d42ef9-7d32-4991-821c-62b03a751ccf"/>
        </asset>
        <asset xsi:type="esdl:HeatingDemand" power="10.0" name="HeatingDemand_d3b9" id="d3b98f6d-abda-4f10-98fc-f9d86f77fbe4">
          <geometry xsi:type="esdl:Point" lon="-20.84587097167969" lat="64.20174575554563"/>
          <port xsi:type="esdl:InPort" id="08332a70-84ef-43bb-8619-a1805dd8a52f" name="In" connectedTo="7a4a907e-331c-49e1-9630-75a50f5ce061"/>
        </asset>
        <geometry xsi:type="esdl:Polygon" CRS="WGS84">
          <exterior xsi:type="esdl:SubPolygon">
            <point xsi:type="esdl:Point" lon="-20.96843719482422" lat="64.24161092467241"/>
            <point xsi:type="esdl:Point" lon="-21.076240539550785" lat="64.22474615860128"/>
            <point xsi:type="esdl:Point" lon="-21.06731414794922" lat="64.1987572878947"/>
            <point xsi:type="esdl:Point" lon="-20.834584960937505" lat="64.19243510075158"/>
            <point xsi:type="esdl:Point" lon="-20.829734802246097" lat="64.23802988755861"/>
          </exterior>
        </geometry>
      </area>
      <area xsi:type="esdl:Area" id="3c9f292f-d7a8-4f0b-b5a8-0b17dc6ca49e" name="Asgard">
        <area xsi:type="esdl:Area" id="befa140e-ae38-4ac9-97c5-09376be5bbad" name="Midgard">
          <asset xsi:type="esdl:WindTurbine" power="120.0" name="WindTurbine_6cb4" technicalLifetime="5.0" id="6cb408e6-ab0c-4d1e-91e8-497a9c1bb21c">
            <geometry xsi:type="esdl:Point" lon="-20.895996093750004" lat="64.294526289623"/>
            <costInformation xsi:type="esdl:CostInformation" id="2e9f6223-d0a8-495a-a217-9a3942f22db0">
              <investmentCosts xsi:type="esdl:SingleValue" id="482d61f7-ea77-4b4a-a811-62b22bc2b171" value="12.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="57ec3f75-71fe-4299-b621-43ed19123132" unit="EURO"/>
              </investmentCosts>
              <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="c782cdd9-e36d-499b-b285-862e1b57a7b9" value="3.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="8b208543-8b4a-4988-be95-cf00ffe37ed2" unit="EURO"/>
              </variableOperationalAndMaintenanceCosts>
            </costInformation>
            <port xsi:type="esdl:OutPort" id="78aa04bd-6e64-40f3-86b2-bab87cf3936e" name="Out" connectedTo="7fd4562a-0345-4aa4-8723-01300f06eada"/>
          </asset>
          <asset xsi:type="esdl:Import" power="40.0" name="Import_56bb" technicalLifetime="1.0" id="56bba6e3-29ae-4b22-9005-111d03d240db">
            <geometry xsi:type="esdl:Point" lon="-20.863037109375004" lat="64.28231259027915"/>
            <costInformation xsi:type="esdl:CostInformation" id="60825dec-e151-4cc0-9d85-e8c15f9f302e">
              <investmentCosts xsi:type="esdl:SingleValue" id="b7c8585b-b67e-4de9-a8e1-730e3e7d40e0" value="45.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="051818ef-c442-419a-ab2c-82477f0acb52" unit="EURO"/>
              </investmentCosts>
              <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="d1b9c17d-21bd-4539-a4bf-0971707f589a" value="1.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="f2b2a2c9-4d8f-488f-9a12-8bd9cbd0832c" unit="EURO"/>
              </variableOperationalAndMaintenanceCosts>
            </costInformation>
            <port xsi:type="esdl:OutPort" id="6a09f018-deea-49c1-94dc-557a5afec0c4" name="Out" connectedTo="7fd4562a-0345-4aa4-8723-01300f06eada"/>
          </asset>
          <asset xsi:type="esdl:ElectricityNetwork" name="ElectricityNetwork_913c" id="913c7dac-c31f-46e3-b42d-2ed501a20be6">
            <geometry xsi:type="esdl:Point" lon="-20.913505554199222" lat="64.27426646921975"/>
            <port xsi:type="esdl:InPort" id="7fd4562a-0345-4aa4-8723-01300f06eada" name="In" connectedTo="dd64ab3d-c368-43f0-9311-c912106e87bb 78aa04bd-6e64-40f3-86b2-bab87cf3936e 6a09f018-deea-49c1-94dc-557a5afec0c4 f0433555-3e3c-4650-83fb-1bdb8e291e86 e2593ac4-78be-431d-b420-1207d7d67ca1"/>
            <port xsi:type="esdl:OutPort" id="f5f4ce72-dc9d-4928-8780-c69655cfe4d6" name="Out" connectedTo="c02a7041-0be1-41b7-ab0a-90e6dfff7169 58194ed4-51ea-4086-abef-e804d11a98c1 4d8e6f38-6ea6-41ea-a08b-25394cb0ed96"/>
          </asset>
          <asset xsi:type="esdl:GasNetwork" name="GasNetwork_0a42" id="0a426095-38cc-4b40-9cfc-bf44d6ff94f7">
            <geometry xsi:type="esdl:Point" lon="-20.853080749511722" lat="64.27024252904668"/>
            <port xsi:type="esdl:InPort" id="6e2be093-7baa-47bb-a98c-6093188845e2" name="In" connectedTo="bea61cda-e8f3-462c-8abb-0ef46298dc81"/>
            <port xsi:type="esdl:OutPort" id="f4126c2b-33ca-472f-b756-fe9894b03236" name="Out" connectedTo="d72b05fd-fd21-436c-bef6-767c2c9f9de4 d720f1c2-04d0-4bd6-b9a5-1fbe8d151427"/>
          </asset>
          <asset xsi:type="esdl:PumpedHydroPower" maxDischargeRate="20.0" maxChargeRate="100.0" name="PumpedHydroPower_eabf" fillLevel="2000.0" capacity="2000.0" technicalLifetime="2.0" id="eabff8a3-a0bc-42da-a9c4-4d094cf2391a">
            <geometry xsi:type="esdl:Point" lon="-20.92552185058594" lat="64.29363278764076"/>
            <costInformation xsi:type="esdl:CostInformation" id="9f61cb4a-50f3-413d-8e92-37b7aeba8b9a">
              <investmentCosts xsi:type="esdl:SingleValue" id="b73b8cc9-3e22-4199-a954-278f7f76a207" value="10.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="dffcb87a-cfcb-4d41-87fc-6ff260d573f6" unit="EURO"/>
              </investmentCosts>
              <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="ca417323-91c8-45ee-b13a-1aba3e072668" value="10.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="82bf3ae5-2daf-4ffe-a9ff-8cf27d250fe3" unit="EURO"/>
              </variableOperationalAndMaintenanceCosts>
            </costInformation>
            <port xsi:type="esdl:InPort" id="58194ed4-51ea-4086-abef-e804d11a98c1" name="In" connectedTo="f5f4ce72-dc9d-4928-8780-c69655cfe4d6"/>
          </asset>
          <asset xsi:type="esdl:ElectricityDemand" power="100.0" name="ElectricityDemand_1e9e" id="1e9ec4ee-e457-4c3c-9957-a4700498bb46">
            <geometry xsi:type="esdl:Point" lon="-20.87539672851563" lat="64.27098774740105"/>
            <port xsi:type="esdl:InPort" id="4d8e6f38-6ea6-41ea-a08b-25394cb0ed96" name="In" connectedTo="f5f4ce72-dc9d-4928-8780-c69655cfe4d6"/>
          </asset>
          <asset xsi:type="esdl:PowerPlant" name="PowerPlant_2d4c" power="20.0" technicalLifetime="1.0" id="2d4c5a85-6765-4c54-9de6-8722256976ff" type="COMBINED_CYCLE_GAS_TURBINE">
            <geometry xsi:type="esdl:Point" lon="-20.852737426757816" lat="64.2781408202984"/>
            <costInformation xsi:type="esdl:CostInformation" id="383a3e95-e07c-47ac-aba5-0cdaca638a75">
              <investmentCosts xsi:type="esdl:SingleValue" id="63ed74c0-6008-49c7-b708-08bcb2f26b9c" value="12.0"/>
              <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="01ddee26-80c4-4964-832b-e8ce113cfe3f" value="12.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="b962f944-536f-4cdc-82ac-99fe266fd3e0" unit="EURO"/>
              </variableOperationalAndMaintenanceCosts>
            </costInformation>
            <port xsi:type="esdl:InPort" id="d720f1c2-04d0-4bd6-b9a5-1fbe8d151427" name="In" connectedTo="f4126c2b-33ca-472f-b756-fe9894b03236"/>
            <port xsi:type="esdl:OutPort" id="f0433555-3e3c-4650-83fb-1bdb8e291e86" name="Out" connectedTo="7fd4562a-0345-4aa4-8723-01300f06eada"/>
          </asset>
          <asset xsi:type="esdl:PowerPlant" name="PowerPlant_4e1c" power="200.0" technicalLifetime="12.0" id="4e1cd004-da90-4135-8399-fb8c56dbdcb3" type="NUCLEAR_3RD_GENERATION">
            <geometry xsi:type="esdl:Point" lon="-20.87608337402344" lat="64.2918456968408" CRS="WGS84"/>
            <costInformation xsi:type="esdl:CostInformation" id="689c8129-5d71-47ad-9c8d-86d569f674f4">
              <investmentCosts xsi:type="esdl:SingleValue" id="7a350f0d-7574-475d-a855-035c409ca4b5" value="20.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="9232171f-c4fb-4059-a1c2-743f072cd93f" unit="EURO"/>
              </investmentCosts>
              <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="120193ee-d5f2-4275-8397-568e6b6b894c" value="20.0">
                <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="49407259-0037-4260-a0db-1ce4ae1233be" unit="EURO"/>
              </variableOperationalAndMaintenanceCosts>
            </costInformation>
            <port xsi:type="esdl:InPort" id="776a35a4-ef22-40a0-b488-94815b1b201a" name="In"/>
            <port xsi:type="esdl:OutPort" id="e2593ac4-78be-431d-b420-1207d7d67ca1" name="Out" connectedTo="7fd4562a-0345-4aa4-8723-01300f06eada"/>
          </asset>
          <geometry xsi:type="esdl:Polygon" CRS="WGS84">
            <exterior xsi:type="esdl:SubPolygon">
              <point xsi:type="esdl:Point" lon="-20.931015014648438" lat="64.26905013784292"/>
              <point xsi:type="esdl:Point" lon="-20.946121215820316" lat="64.29690882007257"/>
              <point xsi:type="esdl:Point" lon="-20.85617065429688" lat="64.30941372865048"/>
              <point xsi:type="esdl:Point" lon="-20.78922271728516" lat="64.29854669036891"/>
              <point xsi:type="esdl:Point" lon="-20.80020904541016" lat="64.26636706936117"/>
            </exterior>
          </geometry>
        </area>
        <asset xsi:type="esdl:ElectricityNetwork" name="ElectricityNetwork_bf61" id="bf612234-bcde-40a1-8c6a-943acf8cefbb">
          <geometry xsi:type="esdl:Point" lon="-21.06353759765625" lat="64.26770863618859"/>
          <port xsi:type="esdl:InPort" id="d6255891-64af-4424-8d7a-b1a0caa79c35" name="In" connectedTo="9bd4851c-7b05-46eb-ae42-21eccc3b17f9 b7b65117-a9fd-4fe9-934d-1626a9939cfe"/>
          <port xsi:type="esdl:OutPort" id="8019638b-ea51-4a66-9d6a-2d7cbb3c2afd" name="Out" connectedTo="69e69ad6-c8c6-4e51-92a6-1baf4bfa2f83 ace3fa7f-b41f-4a47-9cc5-bd172900ad0d efd5ad97-7b65-4acc-8bfc-44fb181daa84 f937380b-3ab1-4e57-b30d-65d90f5b2d4d"/>
        </asset>
        <asset xsi:type="esdl:GasNetwork" name="GasNetwork_6912" id="691233d5-19e0-4338-9b73-fe0ff2b31329">
          <geometry xsi:type="esdl:Point" lon="-21.111946105957035" lat="64.26353465868937"/>
          <port xsi:type="esdl:InPort" id="994cf723-3af6-4d4b-8347-292169d5d1c4" name="In" connectedTo="eeace68b-c6b6-498b-9980-356b6243e122"/>
          <port xsi:type="esdl:OutPort" id="ca13a453-57d1-4a63-b933-ca63fe33af34" name="Out" connectedTo="a4feae4e-b6bd-4a21-b415-002ddf7b5be0 624c451c-6da6-4941-9830-1e0068aa75fb 9b1b3014-be88-4e51-85d7-479a6ed2a42c"/>
        </asset>
        <asset xsi:type="esdl:PVInstallation" power="150.0" name="PVInstallation_e36d" technicalLifetime="2.0" id="e36d17db-241b-4385-b479-b5e62eae095d">
          <geometry xsi:type="esdl:Point" lon="-21.061477661132816" lat="64.28737746326682"/>
          <costInformation xsi:type="esdl:CostInformation" id="bff0b4ab-9959-4b26-9aa4-a2bf0dafadf9">
            <investmentCosts xsi:type="esdl:SingleValue" id="34338b70-ca31-4b62-b610-b3a3793cd344" value="20.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="b52aa3a1-1af8-4a66-9ece-d8e526008848" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="67dde7d3-2a4b-45e6-b85d-a6e84d55eb9c" value="2.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="e7fda4c0-4631-43ba-be45-78be78af4d1e" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:OutPort" id="9bd4851c-7b05-46eb-ae42-21eccc3b17f9" name="Out" connectedTo="d6255891-64af-4424-8d7a-b1a0caa79c35"/>
        </asset>
        <asset xsi:type="esdl:ElectricityDemand" power="150.0" name="ElectricityDemand_928f" id="928f1a33-549d-4e45-86aa-bb2258458a67">
          <geometry xsi:type="esdl:Point" lon="-21.046714782714844" lat="64.26770863618859"/>
          <port xsi:type="esdl:InPort" id="efd5ad97-7b65-4acc-8bfc-44fb181daa84" name="In" connectedTo="8019638b-ea51-4a66-9d6a-2d7cbb3c2afd"/>
        </asset>
        <asset xsi:type="esdl:PowerPlant" efficiency="0.5" name="PowerPlant_4e99" power="1000.0" technicalLifetime="10.0" id="4e9941cd-3e92-4b52-bc66-5ca5e50ec16a" type="COMBINED_CYCLE_GAS_TURBINE">
          <geometry xsi:type="esdl:Point" lon="-21.087913513183597" lat="64.26547265526776"/>
          <costInformation xsi:type="esdl:CostInformation" id="19ae3d7c-5aeb-4429-a943-3d94b30e9851">
            <investmentCosts xsi:type="esdl:SingleValue" id="15a70fe0-6bd4-4525-9128-e10696078e02" value="10.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="14e9ba15-f6ff-4480-840c-01c688b3207c" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="4e6be453-9010-456e-b61d-28c2a010b7cf" value="2.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="196564d6-6a6b-4b26-8088-52a62dc84070" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="9b1b3014-be88-4e51-85d7-479a6ed2a42c" name="In" connectedTo="ca13a453-57d1-4a63-b933-ca63fe33af34"/>
          <port xsi:type="esdl:OutPort" id="b7b65117-a9fd-4fe9-934d-1626a9939cfe" name="Out" connectedTo="d6255891-64af-4424-8d7a-b1a0caa79c35"/>
        </asset>
        <asset xsi:type="esdl:Battery" maxDischargeRate="100.0" maxChargeRate="10.0" name="Battery_0c0a" fillLevel="500.0" capacity="1000.0" technicalLifetime="1.0" id="0c0a3807-db52-4e97-ac63-7ada2603a0a4">
          <geometry xsi:type="esdl:Point" lon="-21.084136962890625" lat="64.27828982294201"/>
          <costInformation xsi:type="esdl:CostInformation" id="8a6e1d2a-c33f-4bf5-ae63-1b27b74e8999">
            <investmentCosts xsi:type="esdl:SingleValue" id="3703658f-f737-4a1c-a1a0-79857f35c75a" value="100.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="934cfee2-ce88-4956-bdf8-79e29cb30360" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="c67c7311-a277-4594-bb43-dba49d881fdc" value="10.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="84e0236f-bb17-4607-8ec6-69a2b6922ff2" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:InPort" id="f937380b-3ab1-4e57-b30d-65d90f5b2d4d" name="In" connectedTo="8019638b-ea51-4a66-9d6a-2d7cbb3c2afd"/>
        </asset>
        <asset xsi:type="esdl:Import" power="100.0" name="Import_d41d" technicalLifetime="1.0" id="d41de9ec-8142-4408-825e-c32a396526ad">
          <geometry xsi:type="esdl:Point" lon="-21.154861450195316" lat="64.28454720766985"/>
          <costInformation xsi:type="esdl:CostInformation" id="09c113d1-0211-4946-9c83-5ff840620fce">
            <investmentCosts xsi:type="esdl:SingleValue" id="56fbcede-ae93-41e0-bc7c-746ce56b9de7" value="10.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh/yr" perMultiplier="MEGA" physicalQuantity="COST" perTimeUnit="YEAR" perUnit="WATTHOUR" id="5046b156-a562-4c6a-9875-0aebd920ea85" unit="EURO"/>
            </investmentCosts>
            <variableOperationalAndMaintenanceCosts xsi:type="esdl:SingleValue" id="edb4688f-bc77-4583-87da-6c917dd16997" value="1.0">
              <profileQuantityAndUnit xsi:type="esdl:QuantityAndUnitType" description="Cost in EUR/MWh" perMultiplier="MEGA" physicalQuantity="COST" perUnit="WATTHOUR" id="323d590e-efe8-41fa-a0ce-3f289fe7622d" unit="EURO"/>
            </variableOperationalAndMaintenanceCosts>
          </costInformation>
          <port xsi:type="esdl:OutPort" id="eeace68b-c6b6-498b-9980-356b6243e122" name="Out" connectedTo="994cf723-3af6-4d4b-8347-292169d5d1c4"/>
        </asset>
        <geometry xsi:type="esdl:Polygon" CRS="WGS84">
          <exterior xsi:type="esdl:SubPolygon">
            <point xsi:type="esdl:Point" lon="-21.105079650878906" lat="64.25995646156042"/>
            <point xsi:type="esdl:Point" lon="-21.18541717529297" lat="64.26085105429894"/>
            <point xsi:type="esdl:Point" lon="-21.20086669921875" lat="64.29541976266103"/>
            <point xsi:type="esdl:Point" lon="-21.144905090332035" lat="64.3039063130678"/>
            <point xsi:type="esdl:Point" lon="-21.05667114257813" lat="64.2983977970889"/>
            <point xsi:type="esdl:Point" lon="-21.038475036621097" lat="64.26547265526776"/>
          </exterior>
        </geometry>
      </area>
      <asset xsi:type="esdl:ElectricityCable" length="7012.8" name="ElectricityCable_c27f" id="c27fa894-f32c-4e6e-b396-bd85deb6aaf0">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-21.054267883300785" lat="64.26219288908568"/>
          <point xsi:type="esdl:Point" lon="-21.035728454589847" lat="64.24892076874816"/>
          <point xsi:type="esdl:Point" lon="-20.946121215820316" lat="64.25026318304684"/>
          <point xsi:type="esdl:Point" lon="-20.93925476074219" lat="64.24220771909953"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="69e69ad6-c8c6-4e51-92a6-1baf4bfa2f83" name="In" connectedTo="8019638b-ea51-4a66-9d6a-2d7cbb3c2afd"/>
        <port xsi:type="esdl:OutPort" id="dcf68219-bdf5-4e35-9053-8bbfbe8feee8" name="Out" connectedTo="5e71413e-6c3c-491f-9aef-f7702dffc477"/>
      </asset>
      <asset xsi:type="esdl:ElectricityCable" length="4785.0" name="ElectricityCable_5e94" id="5e949943-7966-446e-9514-afe5f30668b6">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-21.03916168212891" lat="64.27322328178597"/>
          <point xsi:type="esdl:Point" lon="-20.940628051757816" lat="64.2779918168504"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="ace3fa7f-b41f-4a47-9cc5-bd172900ad0d" name="In" connectedTo="8019638b-ea51-4a66-9d6a-2d7cbb3c2afd"/>
        <port xsi:type="esdl:OutPort" id="dd64ab3d-c368-43f0-9311-c912106e87bb" name="Out" connectedTo="7fd4562a-0345-4aa4-8723-01300f06eada"/>
      </asset>
      <asset xsi:type="esdl:ElectricityCable" length="2848.0" name="ElectricityCable_acfb" id="acfb0111-e7d6-42bd-a2b4-de555304c8e8">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-20.91384887695313" lat="64.26681426554525"/>
          <point xsi:type="esdl:Point" lon="-20.931358337402344" lat="64.24235691569335"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="c02a7041-0be1-41b7-ab0a-90e6dfff7169" name="In" connectedTo="f5f4ce72-dc9d-4928-8780-c69655cfe4d6"/>
        <port xsi:type="esdl:OutPort" id="34823af7-a4d9-4ae5-a715-bbab03bea4ac" name="Out" connectedTo="5e71413e-6c3c-491f-9aef-f7702dffc477"/>
      </asset>
      <asset xsi:type="esdl:Pipe" name="Pipe_2c4b" length="5623.5" id="2c4b3b2f-264f-4027-ae2e-f3ec5cdc0bee">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-21.10954284667969" lat="64.2586145181298"/>
          <point xsi:type="esdl:Point" lon="-21.096153259277347" lat="64.24817495485091"/>
          <point xsi:type="esdl:Point" lon="-21.044998168945316" lat="64.24832411924044"/>
          <point xsi:type="esdl:Point" lon="-21.04019165039063" lat="64.23206046160136"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="a4feae4e-b6bd-4a21-b415-002ddf7b5be0" name="In" connectedTo="ca13a453-57d1-4a63-b933-ca63fe33af34"/>
        <port xsi:type="esdl:OutPort" id="1453f4b9-67eb-40b9-ad5b-2e17f4424e15" name="Out" connectedTo="7b132b24-fb51-45a5-b56a-9f80670eaac7"/>
      </asset>
      <asset xsi:type="esdl:Pipe" name="Pipe_d0f9" length="11264.1" id="d0f9a4d9-2fbe-4c4e-83b7-dcd356ac49cf">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-20.854454040527347" lat="64.26562172629494"/>
          <point xsi:type="esdl:Point" lon="-20.872650146484375" lat="64.25339522950755"/>
          <point xsi:type="esdl:Point" lon="-20.983886718750004" lat="64.25443916611019"/>
          <point xsi:type="esdl:Point" lon="-20.98800659179688" lat="64.24310288658496"/>
          <point xsi:type="esdl:Point" lon="-21.033325195312504" lat="64.2393728308295"/>
          <point xsi:type="esdl:Point" lon="-21.03469848632813" lat="64.23250821324537"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="d72b05fd-fd21-436c-bef6-767c2c9f9de4" name="In" connectedTo="f4126c2b-33ca-472f-b756-fe9894b03236"/>
        <port xsi:type="esdl:OutPort" id="6cfe90b8-2d51-4b3a-b2f4-cef6e0742250" name="Out" connectedTo="7b132b24-fb51-45a5-b56a-9f80670eaac7"/>
      </asset>
      <asset xsi:type="esdl:Pipe" name="Pipe_5563" length="12194.6" id="5563475e-dad4-4ec6-a480-25f29aa09211">
        <geometry xsi:type="esdl:Line" CRS="WGS84">
          <point xsi:type="esdl:Point" lon="-21.101989746093754" lat="64.25876362617463"/>
          <point xsi:type="esdl:Point" lon="-21.096153259277347" lat="64.25533393752119"/>
          <point xsi:type="esdl:Point" lon="-20.983886718750004" lat="64.25906183984983"/>
          <point xsi:type="esdl:Point" lon="-20.880546569824222" lat="64.2577198529598"/>
          <point xsi:type="esdl:Point" lon="-20.86200714111328" lat="64.26606893454861"/>
        </geometry>
        <port xsi:type="esdl:InPort" id="624c451c-6da6-4941-9830-1e0068aa75fb" name="In" connectedTo="ca13a453-57d1-4a63-b933-ca63fe33af34"/>
        <port xsi:type="esdl:OutPort" id="bea61cda-e8f3-462c-8abb-0ef46298dc81" name="Out" connectedTo="6e2be093-7baa-47bb-a98c-6093188845e2"/>
      </asset>
    </area>
  </instance>
</esdl:EnergySystem>
