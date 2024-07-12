import type { FC } from "react";

import data from "@/data";
import { CurrentTime } from "@/components";

const About: FC = ({ }) => {
    return (
        <div className="command-container">
            <div className="w-full gap-4 inline-flex justify-normal items-start">
                <div className="w-36 h-36 bg-zinc-800">
                    <img src="/logo.png" loading="lazy" className="rounded-sm" />
                </div>
                <div className="flex-1 space-y-4">
                    <p>Learn <span className="font-medium glow-white">rustLang</span>{" "}
                        in a web based{" "}
                        <span className="font-medium glow-white"> code sandbox.</span>,  lots of fun projects and guides. lets get rusty!
                    </p>
                    <div>
                        <span>Number of online users: </span>
                        <CurrentTime />
                    </div>
                    <div>
                        <p>feel free to reach out if you have any issue or feature request in mind!</p>
                        <ul className="flex flex-col gap-y-2">
                            {data.socials.map(({ name, value, icon, type }, i) => (
                                <a
                                    href={value}
                                    type={type}
                                    key={i}
                                    target="_blank"
                                    className="space-x-2"
                                >
                                    <span className="text-fuchsia-300 glow-pink">{icon}</span>
                                    <span className="">{name}</span>
                                </a>
                            ))}
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default About;
