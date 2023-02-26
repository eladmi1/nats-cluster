import asyncio
import nats
from nats.errors import ConnectionClosedError, TimeoutError, NoServersError

async def on_subscribe(msg):
    print(f"message: {msg.data.decode()}")

async def main():
    url_list=["nats://client-seed.314d.link:4222","nats://client1.314d.link:4222","nats://client2.314d.link:4222"]
    for sub_url in url_list:
        
        print(f"subscribe URL: {sub_url}")
        nc_sub = await nats.connect(sub_url)
        try:
            sub = await nc_sub.subscribe("my.topic", cb=on_subscribe)
        except Exception as e:
            print("subscription exception")
        
        await asyncio.sleep(5)
        
        for pub_url in url_list:
            print(f"publish URL: {pub_url}")
            nc_pub = await nats.connect(pub_url)
            await sub.unsubscribe(limit=3)
            try:
                await nc_pub.publish("my.topic", b'Hello')
            except Exception as e:
                print("publish exception")
            
        await nc_sub.drain()

asyncio.run(main())
